import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<Map<String, dynamic>> _guesses = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  final TextEditingController _guessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPuzzle();
  }

  Future<void> _fetchPuzzle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("http://localhost:3000/api/puzzle/today");

    try {
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _guesses = List<Map<String, dynamic>>.from(data['guesses']);
        });
      } else {
        setState(() {
          _error = jsonDecode(res.body)['error'] ?? "Failed to Fetch Puzzle";
        });
      }
    } catch (e) {
      setState(() => _error = "Connection Error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitGuess() async {
    final guess = _guessController.text.trim().toLowerCase();
    if (guess.length != 5) {
      setState(() => _error = "Guess must be 5 letters");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("http://localhost:3000/api/puzzle/guess");

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'guess': guess}),
      );

      if (res.statusCode == 200) {
        _guessController.clear();
        await _fetchPuzzle();
      } else {
        final errorMsg = jsonDecode(res.body)['error'];
        setState(() => _error = errorMsg ?? "Invalid Guess");
      }
    } catch (e) {
      setState(() => _error = "Network Error");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wordle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),

            // Guess history
            Expanded(
              child: ListView.builder(
                itemCount: _guesses.length,
                itemBuilder: (context, index) {
                  final entry = _guesses[index];

                  // Safe defaults
                  final guess = (entry['guess'] ?? '').padRight(5).toUpperCase();
                  final feedback = entry['feedback'] ?? List.filled(5, 'absent');

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final letter = guess[i];
                      final result = feedback[i];

                      Color color;
                      switch (result) {
                        case 'Correct':
                          color = Colors.green;
                          break;
                        case 'Misplaced':
                          color = Colors.orange.shade400;
                          break;
                        default:
                          color = Colors.grey;
                      }

                      return Container(
                        margin: const EdgeInsets.all(4),
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Input field and submit button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guessController,
                    decoration: const InputDecoration(hintText: "Enter your guess"),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isLoading || _isSubmitting) ? null : _submitGuess,
                  child: _isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                    : const Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
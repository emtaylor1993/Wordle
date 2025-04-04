/// ****************************************************************************************************
/// File: puzzle_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - Main game screen for the Wordle application. Displays a 6x5 animated grid, handles
///  - user guesses, evaluates feedback, shows win/loss dialogs, and supports dark/light
///  - theming and mobile/desktop controls.
/// 
/// Dependencies:
///  - flutter_dotenv: Loads environment variables from a `.env` file.
///  - provider: State management for theming and authentication.
///  - material.dart: Flutter UI framework.
///  - http: Handles network requests to the backend.
///  - dart:convert: Used for JSON decoding.
///  - dart:math: Used for rotation animation.
///  - dart:io: Platform detection for mobile vs. web.
///****************************************************************************************************
library;

import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/snackbar_helper.dart';
import '../utils/navigation_helper.dart';

/// [PuzzleScreen] is a `StatefulWidget` used for puzzle functionality.
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

/// [_PuzzleScreenState] manages the state of the puzzle screen.
class _PuzzleScreenState extends State<PuzzleScreen> {
  List<Map<String, dynamic>> _guesses = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSolved = false;
  bool _isFailed = false;
  bool _isAnimating = false;

  Duration _timeUntilNextPuzzle = const Duration();
  Timer? _countdownTimer;

  bool get isMobile {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  final TextEditingController _guessController = TextEditingController();
  final baseUrl = dotenv.env['API_BASE_URL'];

  /// Called on widget init to load user profile data.
  @override
  void initState() {
    super.initState();
    _fetchPuzzle();
    _startCountdownTimer();
  }

  /// Fetches the current puzzle state for the user from the backend. Sets the grid state
  /// based on the `guessHistory`, and flags like `_isSolved` or `_isFailed` for UI control.
  /// It will also show a snackbar error if the request fails.
  Future<void> _fetchPuzzle() async {
    setState(() {
      _isLoading = true;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/puzzle/today");

    try {
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _guesses = List<Map<String, dynamic>>.from(data['guesses']);
          _isSolved = data['isSolved'] ?? false;
          _isFailed = _guesses.length >= 6 && !_isSolved;
        });
      } else {
        if (!mounted) return;
        showSnackBar(context, jsonDecode(res.body)['error'] ?? "Failed to Fetch Puzzle", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Connection Error", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Submits the user's guess to the backend. It validates the guess length, sends it to the 
  /// backend, updates the animation state and triggers win/loss dialog based on response.
  Future<void> _submitGuess() async {
    final guess = _guessController.text.trim().toLowerCase();
    if (guess.length != 5) {
      showSnackBar(context, "Guess Must Be 5 Letters", isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isAnimating = true;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/puzzle/guess");

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
        await Future.delayed(const Duration(milliseconds: 50));
        await Future.delayed(const Duration(milliseconds: 750));
        await _fetchPuzzle();
        final data = jsonDecode(res.body);

        if (data['isSolved'] == true) {
          _showResultDialog(isWin: true, streak: data['streak']);
        } else if ((data['attempts'] ?? 0) >= 6) {
          _showResultDialog(isWin: false, correctWord: data['correctWord']);
        }
      } else {
        final errorMsg = jsonDecode(res.body)['error'];
        if (!mounted) return;
        showSnackBar(context, errorMsg ?? "Login Failed", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Network Error", isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
        _isAnimating = false;
      });
    }
  }

  /// Displays a modal dialog with result of the game. Shows either a win message with the
  /// streak or the correct word if failed.
  void _showResultDialog({required bool isWin, String? correctWord, int? streak}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isWin ? '🎉 You Won!' : '😢 You Lost',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWin ? Colors.green : Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isWin && streak != null)
                Text("🔥 Streak: $streak", style: const TextStyle(fontSize: 16)),
              if (!isWin && correctWord != null)
                Text("The word was: $correctWord".toUpperCase(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _startCountdownTimer() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);

    setState(() {
      _timeUntilNextPuzzle = nextMidnight.difference(now);
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      setState(() {
        _timeUntilNextPuzzle = nextMidnight.difference(now);
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wordle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              navigateWithSlide(context, const ProfileScreen());
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              navigateWithSlideReplace(
                context,
                const LoginScreen(),
                direction: SlideDirection.leftToRight,
                arguments: {'success': 'You Have Been Logged Out'},
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 24,
              child: AnimatedOpacity(
                opacity: (_isSolved || _isFailed) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Text(
                    "Next Puzzle: ${_formatDuration(_timeUntilNextPuzzle)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
            // Guess history
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (rowIndex) {
                  final entry = rowIndex < _guesses.length
                    ? _guesses[rowIndex]
                    : {'guess': '', 'feedback': List.filled(5, 'absent')};

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
                          color = Colors.blueGrey;
                      }

                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 300 + (i * 100)),
                        transitionBuilder: (child, animation) {
                          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                          return AnimatedBuilder(
                            animation: rotateAnim,
                            child: child,
                            builder: (context, child) {
                              final isUnderHalf = rotateAnim.value < pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationX(rotateAnim.value),
                                child: isUnderHalf ? child : const SizedBox.shrink(),
                              );
                            },
                          );
                        },
                        child: Container(
                          key: ValueKey("${entry['guess']}_${entry['feedback']?[i] ?? ''}_$i"), // Forces animation on change
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.2 * 255).toInt()),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),

            // Input field and submit button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guessController,
                    enabled: !_isSolved && !_isFailed,
                    decoration: const InputDecoration(hintText: "Enter your guess"),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isLoading || _isSubmitting || _isSolved || _isFailed || _isAnimating) ? null : _submitGuess,
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
            if (isMobile && !_isSolved && !_isFailed)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: 'QWERTYUIOPASDFGHJKLZXCVBNM'.split('').map((char) {
                        return ElevatedButton(
                          onPressed: () {
                            if (_guessController.text.length < 5) {
                              setState(() {
                                _guessController.text += char.toLowerCase();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(40, 40),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(char),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_guessController.text.isNotEmpty) {
                              setState(() {
                                _guessController.text = _guessController.text
                                    .substring(0, _guessController.text.length - 1);
                              });
                            }
                          },
                          icon: const Icon(Icons.backspace),
                          label: const Text("Backspace"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: (_isLoading || _isSubmitting)
                              ? null
                              : _submitGuess,
                          icon: const Icon(Icons.send),
                          label: const Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
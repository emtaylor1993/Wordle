import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  int? _streak;
  String? _profileImage;
  int? _totalGames;
  int? _wins;
  double? _winRate;
  double? _avgGuesses;
  int? _maxStreak;
  bool _isLoading = true;

  final baseUrl = dotenv.env['API_BASE_URL'];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/auth/profile");

    try {
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _username = data['username'];
          _streak = data['streak'];
          _profileImage = data['profileImage'];
          _totalGames = data['totalGames'];
          _wins = data['wins'];
          _winRate = double.tryParse(data['winRate'].toString()) ?? 0.0;
          _avgGuesses = double.tryParse(data['avgGuesses'].toString()) ?? 0.0;
          _maxStreak = data['maxStreak'];
        });
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    if (!mounted) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/auth/profile-image");

    try {
      final request = http.MultipartRequest("POST", uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath("image", pickedFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        _fetchProfile();
      }
    } catch (e) {
      debugPrint("Image upload failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile image
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: _profileImage != null
                              ? NetworkImage("http://localhost:3000/$_profileImage")
                              : const AssetImage("assets/default_avatar.png") as ImageProvider,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _uploadImage,
                          icon: const Icon(Icons.upload),
                          label: const Text("Change Picture"),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _username ?? "User",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text("🔥 Streak: $_streak", style: const TextStyle(fontSize: 16)),

                        const Divider(height: 32),

                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statTile("Games", _totalGames?.toString() ?? "0"),
                            _statTile("Wins", _wins?.toString() ?? "0"),
                            _statTile("Win %", "${_winRate?.toStringAsFixed(1) ?? '0'}%"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statTile("Avg Guesses", _avgGuesses?.toStringAsFixed(1) ?? "0.0"),
                            _statTile("Max Streak", _maxStreak?.toString() ?? "0"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

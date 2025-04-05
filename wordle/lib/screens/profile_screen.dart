/// ****************************************************************************************************
/// File: profile_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - Displays the authenticated user's profile including username, streak, profile picture,
///    and wordle related gameplay statistics. Allows the option to upload a new profile image.
/// 
/// Dependencies:
///  - flutter_dotenv: Loads environment variables from a `.env` file.
///  - provider: State management for theming and authentication.
///  - material.dart: Flutter UI framework.
///  - http: Handles network requests to the backend.
///  - image_picker: Allows image selection.
///  - snackbar_helper: Displays floating feedback messages.
///****************************************************************************************************
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wordle/utils/navigation_helper.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/app_bar.dart';

/// [ProfileScreen] is a `StatefulWidget` used for profile viewing functionality.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// [_ProfileScreenState] manages the state of the profile screen.
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

  /// Called on widget init to load user profile data.
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  /// Fetches profile information from the backend and sets the local state.
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

  /// Opens the image picker and uploads the selected profile image to the server.
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final fileName = pickedFile.name;

    if (!mounted) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse("$baseUrl:3000/api/auth/upload");

    try {
      final request = http.MultipartRequest("POST", uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromBytes("image", bytes, filename: fileName));

      final response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        showSnackBar(context, "Profile Picture Updated!");
        _fetchProfile();
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Image Upload Failed: $e", isError: true);
    }
  }

  /// Builds the profile screen UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: "Profile",
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              navigateWithSlideReplace(
                context,
                const LoginScreen(),
                direction: SlideDirection.leftToRight,
                arguments: {'success': 'Logged Out Successfully!'},
                clearStack: true,
              );
            },
          ),
        ],
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

                        // Profile Image Selection.
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: _profileImage != null
                              ? NetworkImage("$baseUrl:3000/$_profileImage")
                              : const AssetImage("assets/default_avatar.png") as ImageProvider,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _uploadImage,
                          icon: const Icon(Icons.upload),
                          label: const Text("Change Picture"),
                        ),
                        const SizedBox(height: 20),
                        
                        // Username and Streak.
                        Text(
                          _username ?? "User",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text("🔥 Streak: $_streak", style: const TextStyle(fontSize: 16)),

                        const Divider(height: 32),

                        // Gameplay Statistics Row 1.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statTile("Games", _totalGames?.toString() ?? "0"),
                            _statTile("Wins", _wins?.toString() ?? "0"),
                            _statTile("Win %", "${_winRate?.toStringAsFixed(1) ?? '0'}%"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Gameplay Statistics Row 2.
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

  /// Helper method to display the statistics box.
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

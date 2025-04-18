/// =====================================================================================================
/// File: profile_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 7, 2025
///
/// Description: 
///   - Displays the logged-in user's profile info including username, streak, stats, and profile picture.
///   - Allows uploading and persisting a new profile image to the backend.
///
/// Dependencies:
///  - dart:convert: Conversion between JSON and other data representations.
///  - flutter/material.dart: Core Flutter UI toolkit.
///  - flutter_dotenv/flutter_dotenv.dart: Loads environment variables from a `.env` file.
///  - http/http.dart: Handles network requests to backend.
///  - image_picker/image_picker.dart: Used to pick a local image from the user's gallery.
///  - provider/provider.dart: State management for settings and authentication.
///  - screens/statistics_screen.dart: Implementations for the statistics screen.
///  - wordle/providers/auth_provider.dart: Authentication implementations.
///  - wordle/utils/*: Implementations for authentication, settings and snackbar helpers.
///  - wordle/widgets/app_bar.dart: Shared AppBar with logout and settings actions.
/// =====================================================================================================
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/screens/statistics_screen.dart';
import 'package:wordle/utils/auth_helper.dart';
import 'package:wordle/utils/navigation_helper.dart';
import 'package:wordle/utils/settings_helper.dart';
import 'package:wordle/utils/snackbar_helper.dart';
import 'package:wordle/widgets/app_bar.dart';

/// [ProfileScreen] widget for displaying user information and gameplay statistics.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// [_ProfileScreenState] state class that handles API fetch, image upload, and UI updates.
class _ProfileScreenState extends State<ProfileScreen> {
  // User attributes.
  String? _username;
  String? _profileImage;
  bool _isLoading = true;

  // Load API base URL from the environment variables.
  final baseUrl = dotenv.env['API_BASE_URL'];

  /// Fetches profile data on widget load.
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  /// Fetches user profile information from `/api/auth/profile` endpoint.
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
          _profileImage = data['profileImage'];
        });
      } else {
        if (!mounted) return;
        showSnackBar(context, "Failed to Fetch Profile", isError: true);
      }
    } catch (e) {
      debugPrint("[PROFILE] Profile Fetch Error: $e");
      if (!mounted) return;
      showSnackBar(context, "Failed to Fetch Profile", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Allows image upload to the backend from the user's gallery.
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
        ..files.add(http.MultipartFile.fromBytes("image", bytes, filename: fileName));

      final response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        showSnackBar(context, "Profile Picture Updated!");
        _fetchProfile();
      } else {
        if (!mounted) return;
        showSnackBar(context, "Failed to Upload Image", isError: true);
      }
    } catch (e) {
      debugPrint("[PROFILE] Upload Error: $e");
      if (!mounted) return;
      showSnackBar(context, "Image Upload Failed: $e", isError: true);
    }
  }

  /// Builds UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: "Profile",
        onSettingsPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => buildSettingsSheet(context),
          );
        },
        onLogoutPressed: () => handleLogout(context),
        extraActions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              navigateWithSlide(context, const StatisticsScreen());
            },
            tooltip: "Statistics",
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

                        const Divider(height: 32),

                        // Awards Placeholder.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "🏆 Awards",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "No Awards Yet. Keep Playing!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

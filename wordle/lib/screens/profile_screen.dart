import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  int _streak = 0;
  String? _profileImage;
  bool _isLoading = true;
  String? _error;
  final baseUrl = dotenv.env['API_BASE_URL'];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl:3000/api/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _username = data['username'];
          _streak = data['streak'];
          _profileImage = data['profileImage'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to Load Profile";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network Error";
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    if (!mounted) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final uri = Uri.parse('$baseUrl:3000/api/auth/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      _fetchProfile();
    } else {
      setState(() => _error = 'Image Upload Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: _profileImage != null
                                    ? NetworkImage(_profileImage!)
                                    : const AssetImage("../assets/default_avatar.png") as ImageProvider,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _username ?? "Unknown User",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text("🔥 Streak: $_streak",
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _uploadImage,
                                icon: const Icon(Icons.upload),
                                label: const Text("Upload New Picture"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
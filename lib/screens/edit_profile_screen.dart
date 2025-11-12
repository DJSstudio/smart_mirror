import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await AuthService().fetchProfile(); // ✅ use backend API you have

    setState(() {
      _usernameController.text = user?["username"] ?? "";
      _bioController.text = user?["bio"] ?? ""; // if backend doesn't have bio, remains ""
      _loading = false;
    });
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> saveChanges() async {
    setState(() => _loading = true);

    await AuthService().updateProfile(
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      profilePic: _selectedImage, // ✅ Will only upload if image selected
    );

    setState(() => _loading = false);
    Navigator.pop(context, true); // return to refresh profile screen
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 60, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: "Username", labelStyle: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: "Bio (optional)", labelStyle: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}

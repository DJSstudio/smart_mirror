import 'package:flutter/material.dart';
import '../services/user_storage.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Mirror background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter your name",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none, // No box around text
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () async {
                  if (_controller.text.trim().isEmpty) return;
                  await UserStorage.saveUsername(_controller.text.trim());
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

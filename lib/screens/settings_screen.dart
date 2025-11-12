import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(title: Text('Brightness')),
          const Slider(value: 0.5, onChanged: null),
          const Divider(),

          const ListTile(title: Text('Theme')),
          ListTile(
            title: const Text('Reset App'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Reset'),
            ),
          ),

          const Divider(height: 40),

          // ✅ LOGOUT BUTTON
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await AuthService().logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

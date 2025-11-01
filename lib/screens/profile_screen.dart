
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
        SizedBox(height: 12),
        Text('Guest', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        Text('No saved videos', style: TextStyle(color: Colors.white54)),
      ]),
    );
  }
}


import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ListTile(title: Text('Brightness')),
        const Slider(value: 0.5, onChanged: null),
        const Divider(),
        const ListTile(title: Text('Theme')),
        ListTile(title: const Text('Reset App'), trailing: ElevatedButton(onPressed: null, child: const Text('Reset'))),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../widgets/time_display.dart';
import '../widgets/camera_toggle_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tile sizes adjust in portrait mode
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // Top row: Time + Date
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: TimeDisplay(),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(), // reserved for weather / quick info
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tile grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                CameraToggleTile(),
                PlaceholderTile(title: 'Recent Activity'),
                PlaceholderTile(title: 'News Headlines'),
                PlaceholderTile(title: 'Shortcuts'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderTile extends StatelessWidget {
  final String title;
  const PlaceholderTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text('Coming soon', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

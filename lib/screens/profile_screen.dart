// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../utils/platform_view_registry.dart'; // ✅ same helper

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "abc"; // Replace with AuthService user data later
  List<String> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() {
    if (!kIsWeb) return;
    final stored = html.window.localStorage['my_recordings'];
    if (stored != null && stored.isNotEmpty) {
      final urls = stored.split('|');
      for (final url in urls) {
        getPlatformViewRegistry().registerViewFactory(
          url,
          (int viewId) {
            final videoElement = html.VideoElement()
              ..src = url
              ..controls = true
              ..autoplay = false
              ..style.borderRadius = '10px'
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.objectFit = 'cover';
            return videoElement;
          },
        );
      }
      setState(() => _videos = urls);
    }
  }

  void _showVideoPopup(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: HtmlElementView(viewType: url),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 👤 Profile Header
          const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          const SizedBox(height: 10),
          Text(username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 📊 Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat("${_videos.length}", "Videos"),
              const SizedBox(width: 30),
              _buildStat("0", "Photos"),
            ],
          ),
          const SizedBox(height: 20),

          // 🎞️ My Videos Section
          Expanded(
            child: _videos.isEmpty
                ? const Center(
                    child: Text(
                      "No videos recorded yet 🎬",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      final url = _videos[index];
                      return GestureDetector(
                        onTap: () => _showVideoPopup(url),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: HtmlElementView(viewType: url),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Icon(Icons.play_circle_fill,
                                  color: Colors.white70, size: 36),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

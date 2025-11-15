// profile_screen.dart — updated to use PopupVideoPlayer

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/platform_registry.dart';
import 'popup_video_player.dart';
import 'compare_videos_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "User";
  int videoCount = 0;
  int photoCount = 0; // always 0 for now

  List<String> _videos = [];
  List<String> _selected = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadVideos();
  }

  void _loadUserInfo() {
    // Placeholder user for now
    setState(() {
      username = "User";
    });
  }

  void _loadVideos() {
    if (!kIsWeb) return;

    final stored = html.window.localStorage['my_recordings'];
    if (stored != null && stored.isNotEmpty) {
      final urls = stored.split('|');

      videoCount = urls.length;
      photoCount = 0;

      for (final url in urls) {
        getPlatformViewRegistry().registerViewFactory(url + '_thumb', (id) {
          final v = html.VideoElement()
            ..src = url
            ..muted = true
            ..controls = false
            ..autoplay = false
            ..style.objectFit = 'cover'
            ..style.width = '100%'
            ..style.height = '100%';
          return v;
        });
      }

      setState(() => _videos = urls);
    }
  }

  void _toggleSelect(String url) {
    setState(() {
      if (_selected.contains(url)) {
        _selected.remove(url);
      } else if (_selected.length < 2) {
        _selected.add(url);
      }
    });
  }

  void _openPopup(String url) {
    showDialog(
      context: context,
      builder: (_) => PopupVideoPlayer(url: url, allVideos: _videos),
    );
  }

  void _compare() {
    if (_selected.length == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompareVideosScreen(
            leftUrl: _selected[0],
            rightUrl: _selected[1],
          ),
        ),
      ).then((_) => setState(() => _selected.clear()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Profile')),

      floatingActionButton: _selected.length == 2
          ? FloatingActionButton.extended(
              onPressed: _compare,
              label: const Text('Compare'),
              icon: const Icon(Icons.compare),
            )
          : null,

      body: Column(
        children: [
          const SizedBox(height: 20),

          // CENTER USER + COUNTS
          Column(
            children: [
              Text(
                username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "$videoCount",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text("Videos", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      Text(
                        "$photoCount",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text("Photos", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _videos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, i) {
                final url = _videos[i];
                final selected = _selected.contains(url);

                return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: HtmlElementView(viewType: url + '_thumb'),
                      ),

                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openPopup(url),
                          onLongPress: () => _toggleSelect(url),
                        ),
                      ),

                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _toggleSelect(url),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: selected ? Colors.blue : Colors.white54,
                            child: Icon(
                              selected ? Icons.check : Icons.circle,
                              color: Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}

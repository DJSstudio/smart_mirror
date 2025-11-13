// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../utils/platform_view_registry.dart'; // ✅ helper

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "abc"; // Replace with AuthService user data later
  List<String> _videos = [];
  List<String> _selectedVideos = []; // ✅ For comparison selection

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
              ..controls = false
              ..autoplay = false
              ..muted = true
              ..style.pointerEvents = 'none'
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

  void _toggleSelect(String url) {
    setState(() {
      if (_selectedVideos.contains(url)) {
        _selectedVideos.remove(url);
      } else if (_selectedVideos.length < 2) {
        _selectedVideos.add(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can only compare 2 videos.")),
        );
      }
    });
  }

  void _compareSelectedVideos() {
    if (_selectedVideos.length != 2) return;

    final url1 = _selectedVideos[0];
    final url2 = _selectedVideos[1];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => VideoCompareDialog(url1: url1, url2: url2),
    );
  }


//   void _compareSelectedVideos() {
//   if (_selectedVideos.length != 2) return;

//   final url1 = _selectedVideos[0];
//   final url2 = _selectedVideos[1];

//   // Register left video
//   getPlatformViewRegistry().registerViewFactory(
//     'compare_left',
//     (int viewId) {
//       final v = html.VideoElement()
//         ..src = url1
//         ..controls = true
//         ..autoplay = true
//         ..muted = false
//         ..style.width = '100%'
//         ..style.height = '100%'
//         ..style.objectFit = 'contain';
//       return v;
//     },
//   );

//   // Register right video
//   getPlatformViewRegistry().registerViewFactory(
//     'compare_right',
//     (int viewId) {
//       final v = html.VideoElement()
//         ..src = url2
//         ..controls = true
//         ..autoplay = true
//         ..muted = false
//         ..style.width = '100%'
//         ..style.height = '100%'
//         ..style.objectFit = 'contain';
//       return v;
//     },
//   );

//   showDialog(
//     context: context,
//     builder: (_) => Dialog(
//       backgroundColor: Colors.black,
//       child: AspectRatio(
//         aspectRatio: 16 / 9,
//         child: Row(
//           children: [
//             Expanded(child: HtmlElementView(viewType: 'compare_left')),
//             const SizedBox(width: 8),
//             Expanded(child: HtmlElementView(viewType: 'compare_right')),
//           ],
//         ),
//       ),
//     ),
//   );
// }

  void _clearSelection() {
    setState(() => _selectedVideos.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        actions: [
          if (_selectedVideos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: "Clear Selection",
              onPressed: _clearSelection,
            )
        ],
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
                      final isSelected = _selectedVideos.contains(url);

                      return GestureDetector(
                        onTap: () => _toggleSelect(url),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.blueAccent, width: 3)
                                    : null,
                              ),
                              child: HtmlElementView(viewType: url),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.blueAccent
                                    : Colors.white54,
                                radius: 12,
                                child: Icon(
                                  isSelected
                                      ? Icons.check
                                      : Icons.circle_outlined,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // 🎬 Compare Button (only when 2 selected)
      floatingActionButton: _selectedVideos.length == 2
          ? FloatingActionButton.extended(
              onPressed: _compareSelectedVideos,
              backgroundColor: Colors.blueAccent,
              label: const Text("Compare"),
              icon: const Icon(Icons.compare),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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


// -----------------------------------------------------------
// 🔥 Side-by-side Video Compare Dialog
// -----------------------------------------------------------
class VideoCompareDialog extends StatefulWidget {
  final String url1;
  final String url2;

  const VideoCompareDialog({super.key, required this.url1, required this.url2});

  @override
  State<VideoCompareDialog> createState() => _VideoCompareDialogState();
}

class _VideoCompareDialogState extends State<VideoCompareDialog> {
  html.VideoElement? video1;
  html.VideoElement? video2;

  @override
  void initState() {
    super.initState();

    // Create video players
    video1 = html.VideoElement()
      ..src = widget.url1
      ..controls = false
      ..autoplay = false
      ..muted = true
      ..style.objectFit = "contain";

    video2 = html.VideoElement()
      ..src = widget.url2
      ..controls = false
      ..autoplay = false
      ..muted = true
      ..style.objectFit = "contain";

    // Register for Flutter Web view
    getPlatformViewRegistry().registerViewFactory(
      "compare-left",
      (viewId) => video1!,
    );

    getPlatformViewRegistry().registerViewFactory(
      "compare-right",
      (viewId) => video2!,
    );
  }

  void _playBoth() {
    video1?.play();
    video2?.play();
  }

  void _pauseBoth() {
    video1?.pause();
    video2?.pause();
  }

  void _restartBoth() {
    video1?.currentTime = 0;
    video2?.currentTime = 0;
    _playBoth();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // TITLE
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Compare Videos",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Expanded(child: HtmlElementView(viewType: "compare-left")),
                const SizedBox(width: 4),
                Expanded(child: HtmlElementView(viewType: "compare-right")),
              ],
            ),
          ),

          // CONTROL BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.green, size: 30),
                onPressed: _playBoth,
              ),
              IconButton(
                icon: const Icon(Icons.pause, color: Colors.yellow, size: 30),
                onPressed: _pauseBoth,
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt, color: Colors.red, size: 30),
                onPressed: _restartBoth,
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

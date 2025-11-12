// ignore_for_file: avoid_web_libraries_in_flutter, undefined_prefixed_name

import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../utils/platform_view_registry.dart'; // ✅ our helper

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isInitialized = false;

  List<Map<String, dynamic>> _recordings = []; // ✅ Store all past videos

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadRecordings();
  }

  // Load existing recordings from localStorage
  void _loadRecordings() {
    if (!kIsWeb) return;
    final stored = html.window.localStorage['my_recordings'];
    if (stored != null) {
      setState(() {
        _recordings = List<Map<String, dynamic>>.from(
          (html.window.localStorage['my_recordings'] != null)
              ? List<Map<String, dynamic>>.from(
                  (html.window.localStorage['my_recordings']!.split('|')
                      .map((s) => {'url': s}))
                )
              : [],
        );
      });
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint("❌ No cameras found");
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await _controller!.initialize();

      setState(() => _isInitialized = true);
      debugPrint("✅ Camera initialized");
    } catch (e) {
      debugPrint("❌ Error initializing camera: $e");
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      final XFile file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      await _handleRecordedVideo(file);
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _handleRecordedVideo(XFile file) async {
    try {
      final bytes = await file.readAsBytes();

      // ✅ Create blob for web playback and download
      final blob = html.Blob([bytes], 'video/webm');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // ✅ Trigger download automatically
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'smart_mirror_video_${DateTime.now().millisecondsSinceEpoch}.webm')
        ..click();

      // ✅ Register for playback
      if (kIsWeb) {
        getPlatformViewRegistry().registerViewFactory(
          url,
          (int viewId) {
            final videoElement = html.VideoElement()
              ..src = url
              ..controls = true
              ..autoplay = false
              ..style.border = '2px solid #888'
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.borderRadius = '10px'
              ..style.objectFit = 'contain';
            return videoElement;
          },
        );
      }

      // ✅ Save in localStorage for gallery
      _recordings.add({
        'url': url,
        'timestamp': DateTime.now().toIso8601String(),
      });
      html.window.localStorage['my_recordings'] =
          _recordings.map((r) => r['url']).join('|');

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Video recorded & added to gallery")),
      );
    } catch (e) {
      debugPrint("❌ Error handling recorded video: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
        title: const Text("Camera & My Recordings"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 🎥 Live Camera Feed
          Expanded(
            flex: 3,
            child: Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    )
                  : const Text("Loading camera...",
                      style: TextStyle(color: Colors.white)),
            ),
          ),

          const SizedBox(height: 10),

          // 🎞️ My Recordings Gallery
          Expanded(
            flex: 2,
            child: _recordings.isEmpty
                ? const Center(
                    child: Text(
                      "No recordings yet 🎬",
                      style: TextStyle(color: Colors.white54),
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
                    itemCount: _recordings.length,
                    itemBuilder: (context, index) {
                      final rec = _recordings[index];
                      final url = rec['url'];
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

      // 🎬 Record/Stop Button
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRecording,
        backgroundColor: _isRecording ? Colors.red : Colors.white,
        child: Icon(
          _isRecording ? Icons.stop : Icons.videocam,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

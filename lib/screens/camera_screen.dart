// ignore_for_file: avoid_web_libraries_in_flutter, undefined_prefixed_name

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../utils/platform_registry.dart';

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

  @override
  void initState() {
    super.initState();
    _initCamera();
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
      // STOP RECORDING
      final XFile file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      await _saveRecordedFile(file);
    } else {
      // START RECORDING
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _saveRecordedFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();

      final blob = html.Blob([bytes], 'video/webm');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Auto Download
      // final anchor = html.AnchorElement(href: url)
      //   ..setAttribute(
      //     'download',
      //     'smart_mirror_${DateTime.now().millisecondsSinceEpoch}.webm',
      //   )
      //   ..click();

      // Save to localStorage for use in profile page
      final old = html.window.localStorage['my_recordings'];
      if (old == null || old.isEmpty) {
        html.window.localStorage['my_recordings'] = url;
      } else {
        html.window.localStorage['my_recordings'] = "$old|$url";
      }

      debugPrint("🎯 Saved to localStorage: $url");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Video Saved! Check Profile section."),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error saving video: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Record Video"),
      ),

      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              )
            : const Text("Loading camera...",
                style: TextStyle(color: Colors.white)),
      ),

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

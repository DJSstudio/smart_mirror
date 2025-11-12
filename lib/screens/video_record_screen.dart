import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({super.key});

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  CameraController? _controller;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();
    setState(() {});
  }

  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    await _controller!.startVideoRecording();
    setState(() => isRecording = true);
  }

  Future<void> stopRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final video = await _controller!.stopVideoRecording();
    setState(() => isRecording = false);

    Navigator.pop(context, video.path); // return the video path
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: isRecording ? stopRecording : startRecording,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

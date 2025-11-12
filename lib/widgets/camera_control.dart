
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import '../services/video_recorder.dart';

// class CameraControl extends StatefulWidget {
//   const CameraControl({super.key});

//   @override
//   State<CameraControl> createState() => _CameraControlState();
// }

// class _CameraControlState extends State<CameraControl> {
//   CameraController? controller;
//   bool isCameraOn = false;
//   bool isRecording = false;

//   Future<void> startCamera() async {
//     try {
//       final cameras = await availableCameras();
//       controller = CameraController(cameras.first, ResolutionPreset.medium, enableAudio: true);
//       await controller!.initialize();
//       setState(() => isCameraOn = true);
//     } catch (e) {
//       debugPrint('Camera start error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera start error: $e')));
//     }
//   }

//   Future<void> stopCamera() async {
//     try {
//       await controller?.dispose();
//     } catch (_) {}
//     setState(() { isCameraOn = false; isRecording = false; });
//   }

//   Future<void> toggleRecording() async {
//     if (!isRecording) {
//       if (controller == null || !controller!.value.isInitialized) return;
//       setState(() => isRecording = true);
//       await controller!.startVideoRecording();
//     } else {
//       final file = await controller!.stopVideoRecording();
//       setState(() => isRecording = false);
//       final saved = await VideoRecorder.saveFile(file.path);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: \$saved')));
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Expanded(
//         child: Container(
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black),
//           child: isCameraOn && controller != null && controller!.value.isInitialized
//               ? CameraPreview(controller!)
//               : Center(child: Text('Camera is Off', style: TextStyle(color: Colors.white54))),
//         ),
//       ),
//       const SizedBox(height: 8),
//       Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: isCameraOn ? Colors.red : Colors.green),
//           onPressed: () { isCameraOn ? stopCamera() : startCamera(); },
//           child: Text(isCameraOn ? 'Stop Camera' : 'Start Camera'),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton(
//           onPressed: isCameraOn ? toggleRecording : null,
//           child: Text(isRecording ? 'Stop Rec' : 'Record'),
//         ),
//       ])
//     ]);
//   }
// }

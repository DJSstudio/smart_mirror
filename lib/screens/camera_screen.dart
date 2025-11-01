
import 'package:flutter/material.dart';
import '../widgets/camera_control.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Camera', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            SizedBox(height: 12),
            CameraControl(),
          ],
        ),
      ),
    );
  }
}

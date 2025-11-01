
import 'package:flutter/material.dart';
import 'camera_control.dart';

class CameraToggleTile extends StatelessWidget {
  const CameraToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Camera', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Expanded(child: CameraControl()),
      ]),
    );
  }
}

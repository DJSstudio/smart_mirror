import 'dart:async';
import 'package:flutter/material.dart';

class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});

  @override
  State<TimeDisplay> createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  Timer? _timer;
  String _time = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return; // ✅ prevents calling setState() after dispose
    setState(() {
      _time = _formatTime(DateTime.now());
    });
  }

  String _formatTime(DateTime now) {
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ stop timer when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time,
      style: const TextStyle(fontSize: 24, color: Colors.white),
    );
  }
}

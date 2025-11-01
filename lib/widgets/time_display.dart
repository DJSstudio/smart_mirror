
import 'package:flutter/material.dart';
import 'dart:async';

class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});

  @override
  State<TimeDisplay> createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  late String timeString;
  late String dateString;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    timeString = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    dateString = "${now.day}/${now.month}/${now.year}";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(timeString, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300)),
      const SizedBox(height: 8),
      Text(dateString, style: const TextStyle(color: Colors.white70)),
    ]);
  }
}

// compare_videos_screen.dart
// Side-by-side synced playback + timeline slider + overlay (before/after) mode with draggable divider

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/platform_registry.dart';

class CompareVideosScreen extends StatefulWidget {
  final String leftUrl;
  final String rightUrl;

  const CompareVideosScreen({super.key, required this.leftUrl, required this.rightUrl});

  @override
  State<CompareVideosScreen> createState() => _CompareVideosScreenState();
}

class _CompareVideosScreenState extends State<CompareVideosScreen> {
  html.VideoElement? _leftVideo;
  html.VideoElement? _rightVideo;

  double _duration = 1.0;
  double _current = 0.0;
  bool _isReady = false;

  bool _overlayMode = false;
  double _overlayPercent = 0.5; // 0..1 how much of left is visible (in overlay)

  @override
  void initState() {
    super.initState();
    _initVideos();
  }

  void _initVideos() {
    if (!kIsWeb) return;

    _leftVideo = html.VideoElement()
      ..src = widget.leftUrl
      ..controls = false
      ..autoplay = false
      ..muted = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain';

    _rightVideo = html.VideoElement()
      ..src = widget.rightUrl
      ..controls = false
      ..autoplay = false
      ..muted = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain';

    _leftVideo!.onLoadedMetadata.listen((_) {
      final d = _leftVideo!.duration;
      if (!d.isNaN) {
        setState(() {
          _duration = d.toDouble();
          _isReady = true;
        });
      }
    });

    // sync current time updates using left video as master
    _leftVideo!.onTimeUpdate.listen((_) {
      final t = _leftVideo!.currentTime;
      if (!t.isNaN) setState(() => _current = t.toDouble());
      // keep right in sync if difference > small epsilon
      final r = _rightVideo!.currentTime;
      if ((r - t).abs() > 0.05) {
        _rightVideo!.currentTime = t;
      }
    });

    // register view factories for compare view (unique ids)
    getPlatformViewRegistry().registerViewFactory(widget.leftUrl + '_cmp', (id) => _leftVideo!);
    getPlatformViewRegistry().registerViewFactory(widget.rightUrl + '_cmp', (id) => _rightVideo!);
  }

  void _playBoth() {
    _leftVideo?.play();
    _rightVideo?.play();
  }

  void _pauseBoth() {
    _leftVideo?.pause();
    _rightVideo?.pause();
  }

  void _seekBoth(double t) {
    _leftVideo?.currentTime = t;
    _rightVideo?.currentTime = t;
    setState(() => _current = t);
  }

  // overlay drag handler
  void _onOverlayDrag(DragUpdateDetails d, BoxConstraints c) {
    final localDx = d.localPosition.dx;
    final pct = (localDx / c.maxWidth).clamp(0.0, 1.0);
    setState(() => _overlayPercent = pct);
  }

  String _formatTime(double sec) {
    final s = sec.floor();
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return "$m:$ss";
  }

  @override
  void dispose() {
    try {
      _leftVideo?.pause();
      _rightVideo?.pause();
      _leftVideo?.src = '';
      _rightVideo?.src = '';
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftId = widget.leftUrl + '_cmp';
    final rightId = widget.rightUrl + '_cmp';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Compare Videos'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => setState(() => _overlayMode = !_overlayMode),
            child: Text(_overlayMode ? "Side-by-side" : "Overlay", style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          // Durations row (show both video durations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Left: ${_formatTime(_duration)}", style: const TextStyle(color: Colors.white70)),
                Text("Right: ${_formatTime(_duration)}", style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _overlayMode ? _buildOverlayView(leftId, rightId) : _buildSideBySide(leftId, rightId),
            ),
          ),

          // timeline and controls
          if (_isReady)
            Column(
              children: [
                Slider(
                  min: 0,
                  max: _duration,
                  value: _current.clamp(0, _duration),
                  onChanged: (v) => _seekBoth(v),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(_current), style: const TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                          ElevatedButton.icon(onPressed: _playBoth, icon: const Icon(Icons.play_arrow), label: const Text("Play")),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(onPressed: _pauseBoth, icon: const Icon(Icons.pause), label: const Text("Pause")),
                        ],
                      ),
                      Text(_formatTime(_duration), style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSideBySide(String leftId, String rightId) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: HtmlElementView(viewType: leftId)),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: HtmlElementView(viewType: rightId)),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayView(String leftId, String rightId) {
    // overlay: left is base, right is on top, clip right width to overlayPercent
    return LayoutBuilder(
      builder: (context, constraints) {
        final percent = _overlayPercent.clamp(0.0, 1.0);
        final clipWidth = constraints.maxWidth * percent;

        return GestureDetector(
          onHorizontalDragUpdate: (d) => _onOverlayDrag(d, constraints),
          child: Stack(
            children: [
              // base left video
              Positioned.fill(child: HtmlElementView(viewType: leftId)),
              // top right video — clipped to a width equal to overlayPercent * width
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: clipWidth,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0,
                    child: HtmlElementView(viewType: rightId),
                  ),
                ),
              ),

              // draggable divider line
              Positioned(
                left: clipWidth - 2,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: Colors.white24),
              ),
            ],
          ),
        );
      },
    );
  }
}

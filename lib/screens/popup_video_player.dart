// popup_video_player.dart
// A standalone popup player with next/previous navigation
// Works on Flutter Web using HtmlVideoElement

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/platform_registry.dart';

class PopupVideoPlayer extends StatefulWidget {
  final String url;
  final List<String> allVideos;

  const PopupVideoPlayer({super.key, required this.url, required this.allVideos});

  @override
  State<PopupVideoPlayer> createState() => _PopupVideoPlayerState();
}

class _PopupVideoPlayerState extends State<PopupVideoPlayer> {
  html.VideoElement? _player;
  late int _index;
  double _current = 0.0;
  double _duration = 1.0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _index = widget.allVideos.indexOf(widget.url);
    _initPlayer(widget.url);
  }

  void _initPlayer(String url) {
    if (!kIsWeb) return;

    _player = html.VideoElement()
      ..src = url
      ..controls = false
      ..autoplay = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..muted = false;

    _player!.onLoadedMetadata.listen((_) {
      _duration = _player!.duration.toDouble();
      setState(() {});
    });

    _player!.onTimeUpdate.listen((_) {
      setState(() => _current = _player!.currentTime.toDouble());
    });

    getPlatformViewRegistry().registerViewFactory(url + '_popup', (id) => _player!);
    _ready = true;
    setState(() {});
  }

  void _play() => _player?.play();
  void _pause() => _player?.pause();

  void _seek(double t) {
    _player?.currentTime = t;
    setState(() => _current = t);
  }

  void _next() {
    if (_index < widget.allVideos.length - 1) {
      _index++;
      _loadNewVideo(widget.allVideos[_index]);
    }
  }

  void _prev() {
    if (_index > 0) {
      _index--;
      _loadNewVideo(widget.allVideos[_index]);
    }
  }

  void _loadNewVideo(String url) {
    _player?.pause();
    _current = 0;
    _duration = 1;
    _ready = false;
    setState(() {});
    _initPlayer(url);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 900,
        height: 600,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "${_index + 1} / ${widget.allVideos.length}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 40),
              ],
            ),
            Expanded(
              child: HtmlElementView(viewType: widget.allVideos[_index] + '_popup'),
            ),

            if (_ready) ...[
              Slider(
                value: _current.clamp(0, _duration),
                min: 0,
                max: _duration,
                onChanged: (v) => _seek(v),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "${_current.toStringAsFixed(2)} / ${_duration.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  iconSize: 40,
                  onPressed: _prev,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  iconSize: 40,
                  onPressed: _play,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  iconSize: 40,
                  onPressed: _pause,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  iconSize: 40,
                  onPressed: _next,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

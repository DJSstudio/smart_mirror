// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

Future<Uint8List?> generateWebVideoThumbnail(String videoUrl) async {
  final video = html.VideoElement()
    ..src = videoUrl
    ..autoplay = false
    ..muted = true
    ..controls = false;

  await video.play();
  await Future.delayed(const Duration(milliseconds: 500));
  video.pause();

  final canvas = html.CanvasElement(
    width: video.videoWidth,
    height: video.videoHeight,
  );

  final ctx = canvas.context2D;
  ctx.drawImage(video, 0, 0);

  final dataUrl = canvas.toDataUrl("image/png");
  final base64 = dataUrl.split(",").last;

  return Uint8List.fromList(html.window.atob(base64).codeUnits);
}

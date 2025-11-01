
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoRecorder {
  static Future<String> saveFile(String tmpPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = '\${dir.path}/mirror_\${DateTime.now().millisecondsSinceEpoch}.mp4';
    final f = await File(tmpPath).copy(dest);
    return f.path;
  }
}

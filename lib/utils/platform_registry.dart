// lib/utils/platform_registry.dart
// ✅ Safe import for Flutter Web platformViewRegistry

import 'package:flutter/foundation.dart' show kIsWeb;

// This import only exists on web builds — it’s ignored on mobile
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Safely returns the platformViewRegistry (for web only).
dynamic getPlatformViewRegistry() {
  if (kIsWeb) {
    return ui_web.platformViewRegistry;
  } else {
    throw UnsupportedError('platformViewRegistry is only available on Web');
  }
}

import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android emulator, localhost for Web/Windows/macOS/iOS
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000/api';
      default:
        return 'http://localhost:5000/api';
    }
  }
}

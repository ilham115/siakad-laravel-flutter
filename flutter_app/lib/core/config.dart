import 'package:flutter/foundation.dart';

class AppConfig {
  /// Alamat API Laravel (php artisan serve --host=0.0.0.0 --port=8000).
  /// - Web & desktop      : localhost
  /// - Emulator Android   : 10.0.2.2 (alias ke localhost laptop)
  /// - HP asli            : ganti dengan IP laptop, mis. http://192.168.1.10:8000/api
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }
}

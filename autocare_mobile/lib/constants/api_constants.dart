import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    // Nếu có truyền API_BASE_URL khi chạy app thì dùng cái đó
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    // Chạy bằng Chrome Web
    if (kIsWeb) {
      return "https://autocare-api-5a1r.onrender.com";
    }

    // Chạy bằng Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "https://autocare-api-5a1r.onrender.com";
    }

    // Chạy Windows / macOS / Linux desktop
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return "https://autocare-api-5a1r.onrender.com";
    }

    // Mặc định
    return "https://autocare-api-5a1r.onrender.com";
  }

  static String get loginEndpoint => "$baseUrl/api/auth/login";
  static String get registerEndpoint => "$baseUrl/api/auth/register";
  static String get meEndpoint => "$baseUrl/api/users/me";
}
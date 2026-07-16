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
      return "http://localhost:8080";
    }

    // Chạy bằng Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8080";
    }

    // Chạy Windows / macOS / Linux desktop
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return "http://localhost:8080";
    }

    // Mặc định
    return "http://localhost:8080";
  }

  static String get loginEndpoint => "$baseUrl/auth/login";
  static String get registerEndpoint => "$baseUrl/auth/register";
  static String get meEndpoint => "$baseUrl/users/me";
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Chạy Flutter Web Chrome thì dùng localhost
  static const String baseUrl =
      'https://autocare-api-5a1r.onrender.com/api/auth';

  // Nếu chạy Android Emulator thì đổi thành:
  // static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Đăng ký thành công. Vui lòng kiểm tra email để lấy mã xác thực',
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Đăng ký thất bại',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Đăng nhập thành công',
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Đăng nhập thất bại',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server',
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    final url = Uri.parse('$baseUrl/verify-email');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'verificationCode': verificationCode,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Xác thực email thành công',
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Xác thực email thất bại',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server',
      };
    }
  }

  Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/resend-verification-code');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Mã xác thực mới đã được gửi đến email của bạn',
          'token': data['token'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gửi lại mã xác thực thất bại',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server',
      };
    }
  }
}
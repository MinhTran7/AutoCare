import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ProfileService {
  final String baseUrl = 'http://localhost:8080/api/users';

  Future<Map<String, dynamic>> getMe() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Không thể tải thông tin cá nhân');
    }
  }

  Future<Map<String, dynamic>> updateMe({
    required String fullName,
    required String phone,
    required String address,
    String avatarUrl = '',
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'avatarUrl': avatarUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Cập nhật thông tin thất bại');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/me/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Đổi mật khẩu thất bại');
    }
  }
}
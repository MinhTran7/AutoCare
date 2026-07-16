import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class AdminMechanicService {
  static const String baseUrl = 'http://localhost:8080/api/admin/mechanics';

  Future<String> _getToken() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập hoặc token đã hết hạn');
    }

    return token;
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _errorMessage(http.Response response, String defaultMessage) {
    try {
      final data = _decodeBody(response);

      if (data is Map<String, dynamic>) {
        return data['message'] ?? defaultMessage;
      }

      return defaultMessage;
    } catch (_) {
      return defaultMessage;
    }
  }

  Future<List<dynamic>> getMechanics() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'];
      }

      return [];
    }

    throw Exception(
      _errorMessage(response, 'Không tải được danh sách thợ'),
    );
  }

  Future<Map<String, dynamic>> getMechanicById(int mechanicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$mechanicId'),
      headers: await _headers(),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Dữ liệu chi tiết thợ không hợp lệ');
    }

    throw Exception(
      _errorMessage(response, 'Không tải được chi tiết thợ'),
    );
  }

  Future<Map<String, dynamic>> createMechanic({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String address = '',
    String avatarUrl = '',
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'address': address,
        'avatarUrl': avatarUrl,
      }),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception(
      _errorMessage(response, 'Tạo tài khoản thợ thất bại'),
    );
  }

  Future<Map<String, dynamic>> updateMechanic({
    required int mechanicId,
    required String fullName,
    required String phone,
    String address = '',
    String avatarUrl = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$mechanicId'),
      headers: await _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'avatarUrl': avatarUrl,
      }),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception(
      _errorMessage(response, 'Cập nhật thông tin thợ thất bại'),
    );
  }

  Future<Map<String, dynamic>> lockMechanic(
      int mechanicId,
      String reason,
      ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$mechanicId/lock'),
      headers: await _headers(),
      body: jsonEncode({
        'lockedReason': reason,
      }),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception(
      _errorMessage(response, 'Khóa tài khoản thợ thất bại'),
    );
  }

  Future<Map<String, dynamic>> unlockMechanic(int mechanicId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$mechanicId/unlock'),
      headers: await _headers(),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      if (data is Map<String, dynamic>) {
        return data;
      }

      return {};
    }

    throw Exception(
      _errorMessage(response, 'Mở khóa tài khoản thợ thất bại'),
    );
  }
}
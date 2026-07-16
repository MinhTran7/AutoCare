import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class BookingStatusService {
  final String baseUrl = 'http://localhost:8080/api/bookings';

  Future<List<Map<String, dynamic>>> getTimeline(int bookingId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.get(
      Uri.parse('$baseUrl/$bookingId/timeline'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(data);
    throw Exception(data['message'] ?? 'Không thể tải timeline');
  }

  Future<String> getCurrentStatus(int bookingId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.get(
      Uri.parse('$baseUrl/$bookingId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data['status'];
    throw Exception(data['message'] ?? 'Không thể tải trạng thái');
  }

  Future<Map<String, dynamic>> updateStatus(int bookingId, String newStatus, String? note) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.post(
      Uri.parse('$baseUrl/$bookingId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'newStatus': newStatus, 'note': note ?? ''}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Cập nhật trạng thái thất bại');
  }
}
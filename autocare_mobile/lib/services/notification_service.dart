import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class NotificationService {
  final String baseUrl = 'http://localhost:8080/api/notifications';

  Future<List<Map<String, dynamic>>> getAll() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(data);
    throw Exception(data['message'] ?? 'Không thể tải thông báo');
  }

  Future<int> countUnread() async {
    final token = await TokenStorage.getToken();
    if (token == null) return 0;

    final response = await http.get(
      Uri.parse('$baseUrl/unread/count'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['count'] ?? 0;
    }
    return 0;
  }

  Future<void> markAsRead(int notificationId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    await http.patch(
      Uri.parse('$baseUrl/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> markAllAsRead() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    await http.patch(
      Uri.parse('$baseUrl/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> delete(int notificationId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    await http.delete(
      Uri.parse('$baseUrl/$notificationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
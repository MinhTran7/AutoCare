import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ReviewService {
  final String baseUrl = 'http://localhost:8080/api/reviews';

  Future<List<Map<String, dynamic>>> getGarageReviews(int garageId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.get(
      Uri.parse('$baseUrl/garage/$garageId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(data);
    throw Exception(data['message'] ?? 'Không thể tải đánh giá');
  }

  Future<Map<String, dynamic>?> getByBookingId(int bookingId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.get(
      Uri.parse('$baseUrl/booking/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    return null;
  }

  Future<Map<String, dynamic>> createReview({
    required int bookingId,
    required int garageId,
    required int rating,
    String? comment,
    String? images,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.post(
      Uri.parse('$baseUrl/booking/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'garageId': garageId,
        'rating': rating,
        'comment': comment,
        'images': images,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Gửi đánh giá thất bại');
  }

  Future<Map<String, dynamic>> updateReview({
    required int bookingId,
    required int rating,
    String? comment,
    String? images,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.put(
      Uri.parse('$baseUrl/booking/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rating': rating, 'comment': comment, 'images': images}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Cập nhật đánh giá thất bại');
  }

  Future<void> deleteReview(int bookingId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.delete(
      Uri.parse('$baseUrl/booking/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(data['message'] ?? 'Xoá đánh giá thất bại');
    }
  }
}
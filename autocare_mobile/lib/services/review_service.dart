import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../storage/token_storage.dart';

class ReviewService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<Map<String, dynamic>>> getAllServices() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/services'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Không thể tải dịch vụ (status: ${response.statusCode})');
  }

  // Lấy danh sách review của 1 garage, kèm serviceId/serviceName để lọc
  Future<List<Map<String, dynamic>>> getReviewsByGarage(int garageId) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/garage/$garageId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    // FIX: in luôn nội dung lỗi thật từ backend (Spring Boot trả JSON có "message")
    throw Exception('Không thể tải danh sách đánh giá (status: ${response.statusCode}) - Body: ${response.body}');
  }

  Future<Map<String, dynamic>?> getByBookingId(int bookingId) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/booking/$bookingId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    return null;
  }

  // FIX: đổi path thành /reviews/booking/{bookingId} (khớp ReviewController thật),
  // và bookingId nằm trên URL path, không nằm trong body nữa.
  Future<Map<String, dynamic>> createReview({required int bookingId, required int garageId, required int rating, required String comment}) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/reviews/booking/$bookingId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'garageId': garageId, 'rating': rating, 'comment': comment}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // FIX: in nội dung lỗi thật từ backend
      throw Exception('Tạo đánh giá thất bại (status: ${response.statusCode}) - Body: ${response.body}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<Map<String, dynamic>> updateReview({required int bookingId, required int rating, required String comment}) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/reviews/booking/$bookingId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cập nhật đánh giá thất bại (status: ${response.statusCode})');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<void> deleteReview(int bookingId) async {
    final token = await TokenStorage.getToken();
    await http.delete(Uri.parse('$baseUrl/reviews/booking/$bookingId'), headers: {'Authorization': 'Bearer $token'});
  }
}
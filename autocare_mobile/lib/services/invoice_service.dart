import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class InvoiceService {
  final String baseUrl =
      'https://autocare-api-5a1r.onrender.com/api/invoices';

  Future<Map<String, dynamic>> getByBookingId(int bookingId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.get(
      Uri.parse('$baseUrl/booking/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Không thể tải hoá đơn');
  }

  Future<Map<String, dynamic>> createInvoice({
    required int bookingId,
    required double subtotal,
    double discount = 0,
    double taxAmount = 0,
    String paymentMethod = 'CASH',
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bookingId': bookingId,
        'subtotal': subtotal,
        'discount': discount,
        'taxAmount': taxAmount,
        'paymentMethod': paymentMethod,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Tạo hoá đơn thất bại');
  }

  Future<Map<String, dynamic>> markAsPaid(int bookingId, String paymentMethod) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Bạn chưa đăng nhập');

    final response = await http.patch(
      Uri.parse('$baseUrl/booking/$bookingId/pay'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'paymentMethod': paymentMethod}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Thanh toán thất bại');
  }
}
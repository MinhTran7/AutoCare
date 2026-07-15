import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class MechanicApiService {
  Future<List<dynamic>> fetchAssignedBookings() async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/mechanics/my-bookings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<void> updateStatus(String status) async {
    final token = await TokenStorage.getToken();
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/mechanics/status?status=$status'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
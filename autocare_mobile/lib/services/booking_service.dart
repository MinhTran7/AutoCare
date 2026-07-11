import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// Goi cac API cho luong "Dat lich sua chua" (7 man hinh trong mockup).
/// Viet theo dung phong cach VehicleService: tra ve Map/List<Map> tho,
/// khong bao trong wrapper, loi thi doc data['message'].
class BookingService {
  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Man hinh 2: danh sach dich vu. homeOnly=true cho tab "Sua tan noi".
  Future<List<Map<String, dynamic>>> getServices({required bool homeOnly}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/services?homeOnly=$homeOnly'),
      headers: await _headers(),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Khong the tai danh sach dich vu');
    }
  }

  /// Man hinh 3: danh sach garage ho tro dich vu da chon, sap xep gan -> xa.
  Future<List<Map<String, dynamic>>> getGarages({
    int? serviceId,
    double? lat,
    double? lng,
  }) async {
    final params = <String>[];
    if (serviceId != null) params.add('serviceId=$serviceId');
    if (lat != null) params.add('lat=$lat');
    if (lng != null) params.add('lng=$lng');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/garages$query'),
      headers: await _headers(),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Khong the tai danh sach garage');
    }
  }

  /// Man hinh 4: khung gio trong ngay cua 1 garage.
  Future<List<Map<String, dynamic>>> getSlots({
    required int garageId,
    required String date, // dang yyyy-MM-dd
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/garages/$garageId/slots?date=$date'),
      headers: await _headers(),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Khong the tai khung gio');
    }
  }

  /// Man hinh 6 -> 7: tao lich hen.
  Future<Map<String, dynamic>> createBooking({
    required int vehicleId,
    required int garageId,
    required int serviceId,
    required int slotId,
    required String bookingType, // GARAGE hoac HOME
    String? serviceAddress,
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/bookings'),
      headers: await _headers(),
      body: jsonEncode({
        'vehicleId': vehicleId,
        'garageId': garageId,
        'serviceId': serviceId,
        'slotId': slotId,
        'bookingType': bookingType,
        if (serviceAddress != null) 'serviceAddress': serviceAddress,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Dat lich that bai');
    }
  }

  Future<Map<String, dynamic>> getBooking(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/bookings/$id'),
      headers: await _headers(),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Khong the tai lich hen');
    }
  }

  Future<List<Map<String, dynamic>>> getMyBookings(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/bookings/user/$userId'),
      headers: await _headers(),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Khong the tai lich su dat lich');
    }
  }
}
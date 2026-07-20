import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class VehicleService {
  final String baseUrl =
      'https://autocare-api-5a1r.onrender.com/api/vehicles';

  Future<List<Map<String, dynamic>>> getMyVehicles() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Không thể tải danh sách xe');
    }
  }

  Future<Map<String, dynamic>> getVehicleById(int id) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Không thể tải chi tiết xe');
    }
  }

  Future<Map<String, dynamic>> createVehicle({
    required String brand,
    required String model,
    required String licensePlate,
    required int manufacturingYear,
    required String color,
    required int mileage,
    bool isDefault = false,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vehicleType': 'CAR',
        'brand': brand,
        'model': model,
        'licensePlate': licensePlate,
        'manufacturingYear': manufacturingYear,
        'color': color,
        'mileage': mileage,
        'isDefault': isDefault,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Thêm xe thất bại');
    }
  }

  Future<Map<String, dynamic>> updateVehicle({
    required int id,
    required String brand,
    required String model,
    required String licensePlate,
    required int manufacturingYear,
    required String color,
    required int mileage,
    bool isDefault = false,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vehicleType': 'CAR',
        'brand': brand,
        'model': model,
        'licensePlate': licensePlate,
        'manufacturingYear': manufacturingYear,
        'color': color,
        'mileage': mileage,
        'isDefault': isDefault,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Cập nhật xe thất bại');
    }
  }

  Future<void> deleteVehicle(int id) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Xóa xe thất bại');
    }
  }

  Future<Map<String, dynamic>> setDefaultVehicle(int id) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception('Bạn chưa đăng nhập');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/$id/default'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Đặt xe mặc định thất bại');
    }
  }
}
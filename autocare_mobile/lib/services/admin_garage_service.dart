import 'dart:convert';

import 'package:http/http.dart' as http;

import '../admin/admin_api_client.dart';
import '../admin/admin_config.dart';
import '../admin/mock/admin_mock_data.dart';

class AdminGarageService {
  Future<List<Map<String, dynamic>>> getGarages() async {
    if (AdminConfig.useMock) return AdminMockData.garages();

    final response = await http.get(
      Uri.parse('${AdminApiClient.root}/garages'),
      headers: await AdminApiClient.headers(),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMapList(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Không tải được danh sách garage'),
    );
  }

  Future<Map<String, dynamic>> createGarage(Map<String, dynamic> body) async {
    if (AdminConfig.useMock) {
      return {...body, 'id': DateTime.now().millisecondsSinceEpoch};
    }

    final response = await http.post(
      Uri.parse('${AdminApiClient.root}/garages'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode(body),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Tạo garage thất bại'),
    );
  }

  Future<Map<String, dynamic>> updateGarage(
    int id,
    Map<String, dynamic> body,
  ) async {
    if (AdminConfig.useMock) return {...body, 'id': id};

    final response = await http.put(
      Uri.parse('${AdminApiClient.root}/garages/$id'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode(body),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Cập nhật garage thất bại'),
    );
  }

  Future<Map<String, dynamic>> setStatus(int id, String status) async {
    if (AdminConfig.useMock) return {'id': id, 'status': status};

    final response = await http.patch(
      Uri.parse('${AdminApiClient.root}/garages/$id/status'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode({'status': status}),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Đổi trạng thái thất bại'),
    );
  }

  Future<void> deleteGarage(int id) async {
    if (AdminConfig.useMock) return;

    final response = await http.delete(
      Uri.parse('${AdminApiClient.root}/garages/$id'),
      headers: await AdminApiClient.headers(),
    );
    if (response.statusCode == 204 || response.statusCode == 200) return;
    throw Exception(
      AdminApiClient.errorMessage(response, 'Xóa garage thất bại'),
    );
  }
}

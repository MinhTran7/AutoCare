import 'dart:convert';

import 'package:http/http.dart' as http;

import '../admin/admin_api_client.dart';
import '../admin/admin_config.dart';
import '../admin/mock/admin_mock_data.dart';

class AdminServiceCatalogService {
  Future<List<Map<String, dynamic>>> getServices() async {
    if (AdminConfig.useMock) return AdminMockData.services();

    final response = await http.get(
      Uri.parse('${AdminApiClient.root}/services'),
      headers: await AdminApiClient.headers(),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMapList(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Không tải được dịch vụ'),
    );
  }

  Future<Map<String, dynamic>> createService(Map<String, dynamic> body) async {
    if (AdminConfig.useMock) {
      return {...body, 'id': DateTime.now().millisecondsSinceEpoch};
    }

    final response = await http.post(
      Uri.parse('${AdminApiClient.root}/services'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode(body),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Tạo dịch vụ thất bại'),
    );
  }

  Future<Map<String, dynamic>> updateService(
    int id,
    Map<String, dynamic> body,
  ) async {
    if (AdminConfig.useMock) return {...body, 'id': id};

    final response = await http.put(
      Uri.parse('${AdminApiClient.root}/services/$id'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode(body),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Cập nhật dịch vụ thất bại'),
    );
  }

  Future<Map<String, dynamic>> setStatus(int id, String status) async {
    if (AdminConfig.useMock) return {'id': id, 'status': status};

    final response = await http.patch(
      Uri.parse('${AdminApiClient.root}/services/$id/status'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode({'status': status}),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Đổi trạng thái thất bại'),
    );
  }
}

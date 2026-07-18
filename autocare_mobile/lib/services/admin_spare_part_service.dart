import 'dart:convert';

import 'package:http/http.dart' as http;

import '../admin/admin_api_client.dart';
import '../admin/admin_config.dart';
import '../admin/mock/admin_mock_data.dart';

class AdminSparePartService {
  Future<List<Map<String, dynamic>>> getParts() async {
    if (AdminConfig.useMock) return AdminMockData.spareParts();

    final response = await http.get(
      Uri.parse('${AdminApiClient.root}/spare-parts'),
      headers: await AdminApiClient.headers(),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMapList(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Không tải được kho phụ tùng'),
    );
  }

  Future<Map<String, dynamic>> createPart(Map<String, dynamic> body) async {
    if (AdminConfig.useMock) {
      return {...body, 'id': DateTime.now().millisecondsSinceEpoch, 'lowStock': false};
    }

    final response = await http.post(
      Uri.parse('${AdminApiClient.root}/spare-parts'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode(body),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Tạo phụ tùng thất bại'),
    );
  }

  Future<Map<String, dynamic>> updatePart(
    int id,
    Map<String, dynamic> body,
  ) async {
    if (AdminConfig.useMock) return {...body, 'id': id};

    final response = await http.put(
      Uri.parse('${AdminApiClient.root}/spare-parts/$id'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode(body),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Cập nhật phụ tùng thất bại'),
    );
  }

  Future<Map<String, dynamic>> adjustStock(int id, int quantityDelta) async {
    if (AdminConfig.useMock) {
      return {'id': id, 'quantityDelta': quantityDelta};
    }

    final response = await http.patch(
      Uri.parse('${AdminApiClient.root}/spare-parts/$id/stock'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode({'quantityDelta': quantityDelta}),
    );
    final data = AdminApiClient.decode(response);
    if (response.statusCode == 200) return AdminApiClient.asMap(data);
    throw Exception(
      AdminApiClient.errorMessage(response, 'Điều chỉnh tồn kho thất bại'),
    );
  }
}

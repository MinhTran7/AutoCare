import 'dart:convert';

import 'package:http/http.dart' as http;

import '../admin/admin_api_client.dart';
import '../admin/admin_config.dart';
import '../admin/mock/admin_mock_data.dart';

class AdminCustomerService {
  Future<List<Map<String, dynamic>>> getCustomers() async {
    if (AdminConfig.useMock) {
      return AdminMockData.customers();
    }

    final response = await http.get(
      Uri.parse('${AdminApiClient.root}/customers'),
      headers: await AdminApiClient.headers(),
    );
    final data = AdminApiClient.decode(response);

    if (response.statusCode == 200) {
      return AdminApiClient.asMapList(data);
    }

    throw Exception(
      AdminApiClient.errorMessage(response, 'Không tải được danh sách khách'),
    );
  }

  Future<Map<String, dynamic>> lockCustomer(int id, {String? reason}) async {
    if (AdminConfig.useMock) {
      final list = AdminMockData.customers();
      final item = list.firstWhere((e) => e['id'] == id, orElse: () => list.first);
      return {
        ...item,
        'status': 'LOCKED',
        'lockedReason': reason,
      };
    }

    final response = await http.patch(
      Uri.parse('${AdminApiClient.root}/customers/$id/lock'),
      headers: await AdminApiClient.headers(),
      body: jsonEncode({'lockedReason': reason}),
    );
    final data = AdminApiClient.decode(response);

    if (response.statusCode == 200) {
      return AdminApiClient.asMap(data);
    }

    throw Exception(
      AdminApiClient.errorMessage(response, 'Khóa khách hàng thất bại'),
    );
  }

  Future<Map<String, dynamic>> unlockCustomer(int id) async {
    if (AdminConfig.useMock) {
      final list = AdminMockData.customers();
      final item = list.firstWhere((e) => e['id'] == id, orElse: () => list.first);
      return {...item, 'status': 'ACTIVE', 'lockedReason': null};
    }

    final response = await http.patch(
      Uri.parse('${AdminApiClient.root}/customers/$id/unlock'),
      headers: await AdminApiClient.headers(),
    );
    final data = AdminApiClient.decode(response);

    if (response.statusCode == 200) {
      return AdminApiClient.asMap(data);
    }

    throw Exception(
      AdminApiClient.errorMessage(response, 'Mở khóa khách hàng thất bại'),
    );
  }
}

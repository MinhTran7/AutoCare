import 'package:http/http.dart' as http;

import '../admin/admin_api_client.dart';
import '../admin/admin_config.dart';
import '../admin/mock/admin_mock_data.dart';

class AdminDashboardService {
  Future<Map<String, dynamic>> getSummary({String? from, String? to}) async {
    if (AdminConfig.useMock) {
      return AdminMockData.dashboardSummary();
    }

    final query = <String, String>{};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;

    final uri = Uri.parse('${AdminApiClient.root}/dashboard/summary')
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: await AdminApiClient.headers());
    final data = AdminApiClient.decode(response);

    if (response.statusCode == 200) {
      return AdminApiClient.asMap(data);
    }

    throw Exception(
      AdminApiClient.errorMessage(response, 'Không tải được dashboard'),
    );
  }
}

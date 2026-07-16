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
}

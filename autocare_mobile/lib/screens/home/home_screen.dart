import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/notification_service.dart';
import '../../storage/token_storage.dart';
import '../../services/vehicle_service.dart';
import '../booking/repair_type_screen.dart';
import '../booking/select_vehicle_for_booking_screen.dart';
// Nhớ kiểm tra lại đường dẫn import này cho đúng với cấu trúc thư mục của bạn:
import '../tracking/my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VehicleService _vehicleService = VehicleService();
  bool _checkingVehicles = false;

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearAuthData();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  /// Bấm nút "Đặt lịch sửa chữa xe":
  /// - Chưa có xe nào -> báo thêm xe trước.
  /// - Có đúng 1 xe -> vào thẳng màn hình chọn hình thức sửa chữa.
  /// - Có từ 2 xe trở lên -> qua màn hình chọn xe trước.
  Future<void> _goToBooking(BuildContext context) async {
    setState(() => _checkingVehicles = true);
    try {
      final vehicles = await _vehicleService.getMyVehicles();

      if (!mounted) return;
      setState(() => _checkingVehicles = false);

      if (vehicles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Bạn chưa có xe nào, vui lòng thêm xe trước khi đặt lịch')),
        );
        return;
      }

      if (vehicles.length == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RepairTypeScreen(vehicle: vehicles.first)),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SelectVehicleForBookingScreen(vehicles: vehicles)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingVehicles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // Hàm gọi API lấy danh sách lịch hẹn của User
  Future<List<Map<String, dynamic>>> _fetchMyBookings() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.get(
      Uri.parse(
        'https://autocare-api-5a1r.onrender.com/api/bookings/my-bookings',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Lỗi server: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCare Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              final notificationService = NotificationService();
              final dynamicNotifications = await notificationService.getAll();

              if (!context.mounted) return;

              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  alignment: Alignment.topRight,
                  insetPadding: const EdgeInsets.only(top: 56, right: 16, left: 80),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Thông báo của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        dynamicNotifications.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Không có thông báo nào', style: TextStyle(color: Colors.grey)),
                        )
                            : SizedBox(
                          height: 250,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: dynamicNotifications.length,
                            itemBuilder: (context, index) {
                              final n = dynamicNotifications[index];
                              return ListTile(
                                leading: Icon(
                                  n['type'] == 'invoice_ready' ? Icons.receipt_long : Icons.notifications,
                                  color: Colors.blue,
                                ),
                                title: Text(n['title'] ?? 'Thông báo'),
                                subtitle: Text(n['body'] ?? ''),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  final bId = n['bookingId'];
                                  if (bId == null) return;

                                  if (n['type'] == 'invoice_ready') {
                                    Navigator.pushNamed(context, '/invoice', arguments: {'bookingId': bId});
                                  } else {
                                    Navigator.pushNamed(context, '/booking-tracking', arguments: {'bookingId': bId});
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Trang Home',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 1. Hồ sơ cá nhân
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.person),
                  label: const Text('Hồ sơ cá nhân'),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Garage của tôi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/garage'),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Garage xe của tôi'),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Đặt lịch sửa chữa xe
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkingVehicles ? null : () => _goToBooking(context),
                  icon: _checkingVehicles
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.calendar_month),
                  label: const Text('Đặt lịch sửa chữa xe'),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Xem lịch hẹn của bạn (Nút mới thêm - Thực hiện chuyển trang)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('Xem lịch hẹn của bạn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
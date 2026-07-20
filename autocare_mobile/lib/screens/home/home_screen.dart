import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/notification_service.dart';
import '../../storage/token_storage.dart';
import '../../services/vehicle_service.dart';
import '../booking/repair_type_screen.dart';
import '../booking/select_vehicle_for_booking_screen.dart';

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
  
  /// Bam nut "Dat lich sua chua xe":
  /// - Chua co xe nao -> bao them xe truoc.
  /// - Co dung 1 xe -> vao thang man hinh chon hinh thuc sua chua.
  /// - Co tu 2 xe tro len -> qua man hinh chon xe truoc.
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
          // Thay thế nút thông báo tĩnh bằng bộ gọi API động này:
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              // 1. Gọi service lấy thông báo động từ DB lên
              final notificationService = NotificationService();
              final dynamicNotifications = await notificationService.getAll();

              if (!context.mounted) return;

              // 2. Hiển thị Popup
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

                                  // Tự động điều hướng động theo loại thông báo trong DB
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

              // TV1 giữ nguyên
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.person),
                  label: const Text('Hồ sơ cá nhân'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/garage'),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Garage xe của tôi'),
                ),
              ),
              const SizedBox(height: 12),

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

              const SizedBox(height: 24),
              const Divider(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text('Lịch hẹn của bạn (TV3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Gọi bộ dựng tự động dựa vào trạng thái API
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchMyBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.red.shade50,
                      child: const Text(
                        'Không thể tải lịch hẹn. Vui lòng kiểm tra kết nối Backend hoặc đăng nhập lại.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return const Text('Bạn chưa có lịch đặt sửa xe nào.', style: TextStyle(color: Colors.grey));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final bId = booking['id'];
                      final status = booking['status'] ?? 'PENDING';
                      final serviceName = booking['serviceName'] ?? 'Dịch vụ';
                      final garageName = booking['garageName'] ?? 'Garage AutoCare';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã đơn: #$bId', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Dịch vụ: $serviceName tại $garageName'),
                              Text('Trạng thái: $status', style: const TextStyle(color: Colors.blue)),
                              const Divider(),
                              Row(
                                children: [
                                  // 1. Nút Tiến trình (Luôn hiện)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pushNamed(context, '/booking-tracking', arguments: {'bookingId': bId}),
                                      child: const Text('Tiến trình'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // 2. Nút Hoá đơn (Luôn hiện)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pushNamed(context, '/invoice', arguments: {'bookingId': bId}),
                                      child: const Text('Hoá đơn'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8), // Khoảng cách giữa 2 hàng nút
                              Row(
                                children: [
                                  // Nút Xem review & Đánh giá chung (LUÔN HIỆN)
                                  // Thay thế đoạn Expanded hiện tại trong HomeScreen của bạn bằng:
                                  // Tìm đến đoạn nút Đánh giá trong HomeScreen.dart và sửa lại:
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.rate_review, size: 16),
                                      label: const Text('Đánh giá'),
                                      onPressed: () {
                                        // Sửa '/review-page' thành '/review'
                                        Navigator.pushNamed(context, '/review', arguments: {
                                          'bookingId': bId,
                                          'serviceId': booking['serviceId'],
                                          'garageId': booking['garageId'] ?? 1,
                                          'garageName': garageName, // Đảm bảo truyền đủ tham số này
                                          'status': status,
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
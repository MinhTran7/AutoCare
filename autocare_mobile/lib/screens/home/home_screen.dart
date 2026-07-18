import 'package:flutter/material.dart';
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
          const SnackBar(content: Text('Bạn chưa có xe nào, vui lòng thêm xe trước khi đặt lịch')),
        );
        return;
      }

      if (vehicles.length == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RepairTypeScreen(vehicle: vehicles.first)),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SelectVehicleForBookingScreen(vehicles: vehicles)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingVehicles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCare Home'),
        actions: [
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

              // TV1
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'TV3 — Test',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              // TV3
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/booking-tracking',
                    arguments: {'bookingId': 1},
                  ),
                  icon: const Icon(Icons.timeline),
                  label: const Text('Theo dõi lịch hẹn (Booking #1)'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/invoice',
                    arguments: {'bookingId': 1},
                  ),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Hoá đơn (Booking #1)'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  icon: const Icon(Icons.notifications),
                  label: const Text('Thông báo'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/review',
                    arguments: {
                      'bookingId': 3,
                      'garageId': 3,
                      'garageName': 'Garage AutoCare',
                    },
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text('Đánh giá (Booking #3)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../storage/token_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearAuthData();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
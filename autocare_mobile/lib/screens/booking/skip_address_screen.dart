import 'package:flutter/material.dart';

import 'confirm_booking_screen.dart';

/// Man hinh 5B: hien thi khi chon "Den Garage" - khong can nhap dia chi.
class SkipAddressScreen extends StatelessWidget {
  final Map<String, dynamic> draft;

  const SkipAddressScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xac nhan hinh thuc')),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.garage, size: 72, color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Ban se mang xe den Garage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('Bo qua buoc chon dia chi', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmBookingScreen(draft: draft)));
                  },
                  child: const Text('Tiep tuc'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

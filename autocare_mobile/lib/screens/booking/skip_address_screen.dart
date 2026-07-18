import 'package:flutter/material.dart';

import 'confirm_booking_screen.dart';

/// Man hinh 5B: hien thi khi chon "Den Garage" - khong can nhap dia chi,
/// chi thong bao dia chi garage de nguoi dung tu biet duong den.
class SkipAddressScreen extends StatelessWidget {
  final Map<String, dynamic> draft;

  const SkipAddressScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final garage = draft['garage'];
    final String garageName = garage['name'] ?? 'Garage';
    final String? garageAddress = garage['address'];

    return Scaffold(
      appBar: AppBar(title: const Text('Xac nhan hinh thuc')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.garage_rounded, size: 48, color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ban se mang xe den',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      garageName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                    if (garageAddress != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              garageAddress,
                              style: const TextStyle(color: Colors.grey, fontSize: 13.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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
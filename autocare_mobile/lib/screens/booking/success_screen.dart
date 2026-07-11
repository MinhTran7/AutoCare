import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Man hinh 7: "Dat lich thanh cong"
class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const SuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking['bookingDate'] ?? '');
    final startTime = (booking['startTime'] as String?)?.substring(0, 5) ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 44,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 16),
              const Text('Dat lich thanh cong!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
              const SizedBox(height: 8),
              const Text('Ma lich hen cua ban', style: TextStyle(color: Colors.grey)),
              Text('#${booking['bookingCode'] ?? ''}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(date != null ? '${DateFormat('dd/MM/yyyy').format(date)}  •  $startTime' : ''),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.store_mall_directory_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(booking['garageName'] ?? '')),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.build_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(booking['serviceName'] ?? '')),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.place_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(booking['displayAddress'] ?? '')),
                      ]),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Ve trang chu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

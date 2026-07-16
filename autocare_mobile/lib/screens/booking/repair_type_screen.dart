import 'package:flutter/material.dart';

import 'service_list_screen.dart';

/// Man hinh 1: "Chon hinh thuc sua chua"
/// Vao tu man hinh chi tiet xe: Navigator.push(..., RepairTypeScreen(vehicle: vehicle))
class RepairTypeScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const RepairTypeScreen({super.key, required this.vehicle});

  void _choose(BuildContext context, String bookingType) {
    final draft = <String, dynamic>{
      'vehicle': vehicle,
      'bookingType': bookingType, // GARAGE hoac HOME
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceListScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chon hinh thuc sua chua')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ban muon sua xe theo hinh thuc nao?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.garage, size: 32),
                title: const Text('Den Garage'),
                subtitle: const Text(
                  'Mang xe den hang de duoc kiem tra va sua chua.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _choose(context, 'GARAGE'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.green.withOpacity(0.05),
              child: ListTile(
                leading: const Icon(Icons.moped, size: 32, color: Colors.green),
                title: const Text('Sua chua tan noi'),
                subtitle: const Text(
                  'Tho sua den dia diem cua ban (chi ap dung mot so dich vu).',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _choose(context, 'HOME'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

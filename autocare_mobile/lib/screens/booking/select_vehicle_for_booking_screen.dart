import 'package:flutter/material.dart';

import 'repair_type_screen.dart';

/// Man hinh chon xe truoc khi dat lich, chi hien thi khi nguoi dung co
/// tu 2 xe tro len. Neu chi co 1 xe thi HomeScreen se bo qua man hinh nay.
class SelectVehicleForBookingScreen extends StatelessWidget {
  final List<Map<String, dynamic>> vehicles;

  const SelectVehicleForBookingScreen({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn xe cần sửa')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          final isDefault = vehicle['isDefault'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(
                '${vehicle['brand']} ${vehicle['model']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Biển số: ${vehicle['licensePlate']}'
                    '${isDefault ? '  •  Xe mặc định' : ''}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RepairTypeScreen(vehicle: vehicle)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
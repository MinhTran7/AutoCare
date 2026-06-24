import 'package:flutter/material.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key});

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final bool isDefault = vehicle['isDefault'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết xe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    '${vehicle['brand']} ${vehicle['model']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _infoRow('Biển số', vehicle['licensePlate'] ?? ''),
                _infoRow('Hãng xe', vehicle['brand'] ?? ''),
                _infoRow('Dòng xe', vehicle['model'] ?? ''),
                _infoRow(
                  'Năm sản xuất',
                  '${vehicle['manufacturingYear'] ?? 'Chưa cập nhật'}',
                ),
                _infoRow('Màu xe', vehicle['color'] ?? 'Chưa cập nhật'),
                _infoRow('Số km', '${vehicle['mileage'] ?? 0} km'),
                _infoRow(
                  'Xe mặc định',
                  isDefault ? 'Có' : 'Không',
                ),
                _infoRow(
                  'Trạng thái',
                  vehicle['status']?.toString() ?? '',
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/edit-vehicle',
                        arguments: vehicle,
                      );

                      if (result == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa thông tin xe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
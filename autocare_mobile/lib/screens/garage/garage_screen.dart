import 'package:flutter/material.dart';

import '../../services/vehicle_service.dart';
import '../booking/repair_type_screen.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final VehicleService _vehicleService = VehicleService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final data = await _vehicleService.getMyVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _deleteVehicle(int id) async {
    try {
      await _vehicleService.deleteVehicle(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa xe thành công')),
      );

      _loadVehicles();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _setDefaultVehicle(int id) async {
    try {
      await _vehicleService.setDefaultVehicle(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt xe mặc định thành công')),
      );

      _loadVehicles();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa xe'),
          content: const Text('Bạn có chắc chắn muốn xóa xe này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVehicle(id);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final int id = vehicle['id'];
    final bool isDefault = vehicle['isDefault'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.directions_car),
        title: Text(
          '${vehicle['brand']} ${vehicle['model']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Biển số: ${vehicle['licensePlate']}\n'
              'Màu: ${vehicle['color'] ?? 'Chưa cập nhật'} - '
              'Km: ${vehicle['mileage'] ?? 0}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              tooltip: 'Đặt lịch sửa chữa',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RepairTypeScreen(vehicle: vehicle)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/edit-vehicle',
                  arguments: vehicle,
                );

                if (result == true) {
                  _loadVehicles();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _confirmDelete(id);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/vehicle-detail',
            arguments: vehicle,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage xe của tôi'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVehicles,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _vehicles.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.directions_car, size: 80),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Bạn chưa có xe nào',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _vehicles.length,
          itemBuilder: (context, index) {
            return _buildVehicleCard(_vehicles[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-vehicle');

          if (result == true) {
            _loadVehicles();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
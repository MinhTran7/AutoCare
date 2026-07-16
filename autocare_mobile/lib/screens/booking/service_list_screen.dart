import 'package:flutter/material.dart';

import '../../services/booking_service.dart';
import 'garage_list_screen.dart';

/// Man hinh 2: "Chon dich vu sua chua" / "Dich vu tan noi"
class ServiceListScreen extends StatefulWidget {
  final Map<String, dynamic> draft;

  const ServiceListScreen({super.key, required this.draft});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final BookingService _bookingService = BookingService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _services = [];

  bool get _isHome => widget.draft['bookingType'] == 'HOME';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final data = await _bookingService.getServices(homeOnly: _isHome);
      if (!mounted) return;
      setState(() {
        _services = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _selectService(Map<String, dynamic> service) {
    final newDraft = Map<String, dynamic>.from(widget.draft)
      ..['service'] = service;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GarageListScreen(draft: newDraft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isHome ? 'Dich vu tan noi' : 'Chon dich vu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
          ? const Center(child: Text('Khong co dich vu phu hop'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final s = _services[index];
                final price = (s['price'] as num?)?.toDouble() ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.build_outlined),
                    title: Text(s['name'] ?? ''),
                    trailing: Text(
                      '${_formatPrice(price)}d',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _selectService(s),
                  ),
                );
              },
            ),
    );
  }

  String _formatPrice(double p) {
    final s = p.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }
}

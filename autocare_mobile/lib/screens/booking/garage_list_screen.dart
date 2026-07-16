import 'package:flutter/material.dart';

import '../../services/booking_service.dart';
import 'datetime_screen.dart';

/// Man hinh 3: "Chon Garage"
class GarageListScreen extends StatefulWidget {
  final Map<String, dynamic> draft;

  const GarageListScreen({super.key, required this.draft});

  @override
  State<GarageListScreen> createState() => _GarageListScreenState();
}

class _GarageListScreenState extends State<GarageListScreen> {
  final BookingService _bookingService = BookingService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _garages = [];
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadGarages();
  }

  Future<void> _loadGarages() async {
    try {
      final serviceId = widget.draft['service']['id'];
      // TODO: thay lat/lng cung bang vi tri GPS thuc te (dung package geolocator)
      final data = await _bookingService.getGarages(
        serviceId: serviceId,
        lat: 21.0278,
        lng: 105.8342,
      );
      if (!mounted) return;
      setState(() {
        _garages = data;
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

  void _continue() {
    final garage = _garages.firstWhere((g) => g['id'] == _selectedId);
    final newDraft = Map<String, dynamic>.from(widget.draft)
      ..['garage'] = garage;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DateTimeScreen(draft: newDraft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chon Garage')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _garages.isEmpty
          ? const Center(child: Text('Khong co garage nao ho tro dich vu nay'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _garages.length,
                    itemBuilder: (context, index) {
                      final g = _garages[index];
                      final selected = _selectedId == g['id'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: selected ? Colors.blue.withOpacity(0.06) : null,
                        child: ListTile(
                          leading: const Icon(
                            Icons.store_mall_directory_outlined,
                          ),
                          title: Text(g['name'] ?? ''),
                          subtitle: Text(
                            [
                              if (g['address'] != null) g['address'],
                              if (g['distanceKm'] != null)
                                '${g['distanceKm']} km',
                            ].join(' • '),
                          ),
                          trailing: Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected ? Colors.blue : Colors.grey,
                          ),
                          onTap: () => setState(() => _selectedId = g['id']),
                        ),
                      );
                    },
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
                        onPressed: _selectedId == null ? null : _continue,
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

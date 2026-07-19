import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/booking_service.dart';
import 'success_screen.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final Map<String, dynamic> draft;
  const ConfirmBookingScreen({super.key, required this.draft});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final BookingService _bookingService = BookingService();
  bool _submitting = false;

  List<Map<String, dynamic>> get _services => List<Map<String, dynamic>>.from(widget.draft['services']);

  num get _totalPrice => _services.fold<num>(0, (sum, s) => sum + ((s['price'] as num?) ?? 0));

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final draft = widget.draft;
      final isHome = draft['bookingType'] == 'HOME';

      final result = await _bookingService.createBooking(
        vehicleId: draft['vehicle']['id'],
        garageId: draft['garage']['id'],
        serviceIds: _services.map<int>((s) => s['id'] as int).toList(),
        slotId: draft['slot']['id'],
        bookingType: draft['bookingType'],
        serviceAddress: isHome ? draft['address'] : null,
      );

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SuccessScreen(booking: result)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _formatPrice(num p) {
    final s = p.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final vehicle = draft['vehicle'];
    final garage = draft['garage'];
    final slot = draft['slot'];
    final isHome = draft['bookingType'] == 'HOME';
    final address = isHome ? (draft['address'] ?? '') : (garage['address'] ?? '');
    final date = DateTime.tryParse(draft['bookingDate']);
    final startTime = (slot['startTime'] as String).substring(0, 5);

    return Scaffold(
      appBar: AppBar(title: const Text('Xac nhan dat lich')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _row('Hinh thuc sua chua', isHome ? 'Sua tan noi' : 'Den Garage'),
                        _row('Garage', garage['name'] ?? ''),
                        _row('Xe', '${vehicle['brand']} ${vehicle['model']} - ${vehicle['licensePlate']}'),
                        _row('Ngay', date != null ? DateFormat('dd/MM/yyyy').format(date) : ''),
                        _row('Gio', startTime),
                        _row('Dia diem', address),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dich vu da chon', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ..._services.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(s['name'] ?? '')),
                              Text('${_formatPrice((s['price'] as num?) ?? 0)}đ'),
                            ],
                          ),
                        )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tong tien du kien', style: TextStyle(color: Colors.grey)),
                            Text(
                              '${_formatPrice(_totalPrice)}đ',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Dat lich'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
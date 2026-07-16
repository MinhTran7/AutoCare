import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/booking_service.dart';
import 'address_screen.dart';
import 'skip_address_screen.dart';

/// Man hinh 4: "Chon ngay gio"
class DateTimeScreen extends StatefulWidget {
  final Map<String, dynamic> draft;

  const DateTimeScreen({super.key, required this.draft});

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  final BookingService _bookingService = BookingService();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];
  int? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _selectedSlotId = null;
    });
    try {
      final garageId = widget.draft['garage']['id'];
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final data = await _bookingService.getSlots(
        garageId: garageId,
        date: dateStr,
      );
      if (!mounted) return;
      setState(() {
        _slots = data;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadSlots();
    }
  }

  void _continue() {
    final slot = _slots.firstWhere((s) => s['id'] == _selectedSlotId);
    final newDraft = Map<String, dynamic>.from(widget.draft)
      ..['bookingDate'] = DateFormat('yyyy-MM-dd').format(_selectedDate)
      ..['slot'] = slot;

    if (widget.draft['bookingType'] == 'HOME') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddressScreen(draft: newDraft)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SkipAddressScreen(draft: newDraft)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chon ngay gio')),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(
              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
            ),
            trailing: TextButton(
              onPressed: _pickDate,
              child: const Text('Doi ngay'),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chon khung gio',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _slots.isEmpty
                ? const Center(child: Text('Garage khong lam viec ngay nay'))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.4,
                        ),
                    itemCount: _slots.length,
                    itemBuilder: (context, index) {
                      final s = _slots[index];
                      final available = s['status'] == 'AVAILABLE';
                      final selected = _selectedSlotId == s['id'];
                      final startTime = (s['startTime'] as String).substring(
                        0,
                        5,
                      );
                      return OutlinedButton(
                        onPressed: available
                            ? () => setState(() => _selectedSlotId = s['id'])
                            : null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected
                              ? Theme.of(context).primaryColor
                              : null,
                          foregroundColor: selected ? Colors.white : null,
                        ),
                        child: Text(startTime),
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
                  onPressed: _selectedSlotId == null ? null : _continue,
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

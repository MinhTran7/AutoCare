import 'package:flutter/material.dart';

import '../../services/booking_service.dart';
import 'garage_list_screen.dart';

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
  final Set<int> _selectedIds = {};

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

  void _toggle(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _continue() {
    final selected = _services.where((s) => _selectedIds.contains(s['id'])).toList();
    final newDraft = Map<String, dynamic>.from(widget.draft)..['services'] = selected;
    Navigator.push(context, MaterialPageRoute(builder: (_) => GarageListScreen(draft: newDraft)));
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
    return Scaffold(
      appBar: AppBar(title: Text(_isHome ? 'Dich vu tan noi' : 'Chon dich vu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_services.isEmpty)
            const Expanded(child: Center(child: Text('Khong co dich vu phu hop')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final s = _services[index];
                  final id = s['id'] as int;
                  final price = (s['price'] as num?) ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: CheckboxListTile(
                      value: _selectedIds.contains(id),
                      onChanged: (_) => _toggle(id),
                      secondary: const Icon(Icons.build_outlined),
                      title: Text(s['name'] ?? ''),
                      subtitle: Text('${_formatPrice(price)}đ'),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                  );
                },
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedIds.isEmpty ? null : _continue,
                  child: Text(_selectedIds.isEmpty ? 'Chon it nhat 1 dich vu' : 'Tiep tuc (${_selectedIds.length} dich vu)'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
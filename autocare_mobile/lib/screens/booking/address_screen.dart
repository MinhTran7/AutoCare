import 'package:flutter/material.dart';

import 'confirm_booking_screen.dart';

/// Man hinh 5A: "Chon dia diem sua chua" (chi hien thi khi Sua tan noi).
///
/// Ghi chu: schema DB hien chua co bang luu nhieu dia chi cho 1 user,
/// nen dang dung danh sach mau (Nha / Cong ty) + o nhap dia chi moi.
class AddressScreen extends StatefulWidget {
  final Map<String, dynamic> draft;

  const AddressScreen({super.key, required this.draft});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _customController = TextEditingController();
  int? _selectedIndex;

  final List<Map<String, String>> _savedAddresses = const [
    {'label': 'Nha', 'address': '123 Nguyen Trai, Quan 1, TP. HCM'},
    {'label': 'Cong ty', 'address': '456 Le Loi, Quan 1, TP. HCM'},
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _selectedIndex != null || _customController.text.trim().isNotEmpty;

  void _continue() {
    final address = _selectedIndex != null
        ? _savedAddresses[_selectedIndex!]['address']!
        : _customController.text.trim();

    final newDraft = Map<String, dynamic>.from(widget.draft)
      ..['address'] = address;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmBookingScreen(draft: newDraft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chon dia diem')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Dia chi da luu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._savedAddresses.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  final selected = _selectedIndex == i;
                  return Card(
                    color: selected ? Colors.blue.withOpacity(0.06) : null,
                    child: ListTile(
                      leading: Icon(
                        item['label'] == 'Nha'
                            ? Icons.home_outlined
                            : Icons.apartment_outlined,
                      ),
                      title: Text(item['label']!),
                      subtitle: Text(item['address']!),
                      trailing: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected ? Colors.blue : Colors.grey,
                      ),
                      onTap: () => setState(() {
                        _selectedIndex = i;
                        _customController.clear();
                      }),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Nhap dia chi khac',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _customController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Vi du: 15 Nguyen Chi Thanh, Ha Noi',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _selectedIndex = null),
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
                  onPressed: _canContinue ? _continue : null,
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

import 'package:flutter/material.dart';

import '../../services/admin_spare_part_service.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final AdminSparePartService _service = AdminSparePartService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getParts();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  bool _isLow(Map<String, dynamic> item) {
    if (item['lowStock'] == true) return true;
    final qty = item['quantityInStock'];
    final min = item['minStockLevel'];
    if (qty is num && min is num) return qty <= min;
    return false;
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final nameCtrl =
        TextEditingController(text: '${existing?['partName'] ?? ''}');
    final unitCtrl = TextEditingController(text: '${existing?['unit'] ?? ''}');
    final priceCtrl =
        TextEditingController(text: '${existing?['unitPrice'] ?? ''}');
    final qtyCtrl =
        TextEditingController(text: '${existing?['quantityInStock'] ?? '0'}');
    final minCtrl =
        TextEditingController(text: '${existing?['minStockLevel'] ?? '0'}');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Thêm phụ tùng' : 'Sửa phụ tùng'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên phụ tùng'),
                ),
                TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Đơn giá'),
                ),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tồn kho'),
                ),
                TextField(
                  controller: minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Mức tối thiểu'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    final body = {
      'partName': nameCtrl.text.trim(),
      'unit': unitCtrl.text.trim(),
      'unitPrice': double.tryParse(priceCtrl.text.trim()) ?? 0,
      'quantityInStock': int.tryParse(qtyCtrl.text.trim()) ?? 0,
      'minStockLevel': int.tryParse(minCtrl.text.trim()) ?? 0,
      'status': 'ACTIVE',
    };

    nameCtrl.dispose();
    unitCtrl.dispose();
    priceCtrl.dispose();
    qtyCtrl.dispose();
    minCtrl.dispose();

    if (saved != true) return;

    try {
      if (existing == null) {
        await _service.createPart(body);
      } else {
        await _service.updatePart(existing['id'] as int, body);
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _adjust(Map<String, dynamic> item, int delta) async {
    try {
      await _service.adjustStock(item['id'] as int, delta);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm phụ tùng'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final low = _isLow(item);
                      return Card(
                        color: low ? Colors.red.shade50 : Colors.white,
                        child: ListTile(
                          title: Text(
                            '${item['partName']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: low ? Colors.red.shade800 : null,
                            ),
                          ),
                          subtitle: Text(
                            'Tồn: ${item['quantityInStock']} ${item['unit']}'
                            ' · Min: ${item['minStockLevel']}'
                            ' · Giá: ${item['unitPrice']}'
                            '${low ? '\n⚠ Sắp hết hàng' : ''}',
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            children: [
                              IconButton(
                                tooltip: 'Xuất -1',
                                onPressed: () => _adjust(item, -1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              IconButton(
                                tooltip: 'Nhập +1',
                                onPressed: () => _adjust(item, 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                onPressed: () => _openForm(existing: item),
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

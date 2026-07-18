import 'package:flutter/material.dart';

import '../../services/admin_service_catalog_service.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final AdminServiceCatalogService _service = AdminServiceCatalogService();
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
      final list = await _service.getServices();
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

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(text: '${existing?['name'] ?? ''}');
    final descCtrl =
        TextEditingController(text: '${existing?['description'] ?? ''}');
    final priceCtrl =
        TextEditingController(text: '${existing?['price'] ?? ''}');
    var isHome = existing?['isHomeService'] == true;
    var status = '${existing?['status'] ?? 'ACTIVE'}';

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(existing == null ? 'Thêm dịch vụ' : 'Sửa dịch vụ'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Tên'),
                      ),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Mô tả'),
                      ),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Giá'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dịch vụ tận nơi (HOME)'),
                        value: isHome,
                        onChanged: (v) => setLocal(() => isHome = v),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        items: const [
                          DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                          DropdownMenuItem(
                            value: 'INACTIVE',
                            child: Text('INACTIVE'),
                          ),
                        ],
                        onChanged: (v) => setLocal(() => status = v ?? 'ACTIVE'),
                        decoration: const InputDecoration(labelText: 'Status'),
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
            );
          },
        );
      },
    );

    if (saved != true) {
      nameCtrl.dispose();
      descCtrl.dispose();
      priceCtrl.dispose();
      return;
    }

    final body = {
      'name': nameCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
      'isHomeService': isHome,
      'status': status,
    };

    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();

    try {
      if (existing == null) {
        await _service.createService(body);
      } else {
        await _service.updateService(existing['id'] as int, body);
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> item) async {
    final current = '${item['status']}'.toUpperCase();
    final next = current == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await _service.setStatus(item['id'] as int, next);
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
        label: const Text('Thêm dịch vụ'),
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
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${item['name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Giá: ${item['price']}\n'
                            '${item['isHomeService'] == true ? 'HOME' : 'GARAGE'} · ${item['status']}',
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openForm(existing: item),
                              ),
                              IconButton(
                                icon: Icon(
                                  '${item['status']}'.toUpperCase() == 'ACTIVE'
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color:
                                      '${item['status']}'.toUpperCase() == 'ACTIVE'
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                                onPressed: () => _toggleStatus(item),
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

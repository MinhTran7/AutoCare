import 'package:flutter/material.dart';

import '../../services/admin_garage_service.dart';

class AdminGaragesScreen extends StatefulWidget {
  const AdminGaragesScreen({super.key});

  @override
  State<AdminGaragesScreen> createState() => _AdminGaragesScreenState();
}

class _AdminGaragesScreenState extends State<AdminGaragesScreen> {
  final AdminGarageService _service = AdminGarageService();
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
      final list = await _service.getGarages();
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
    final addressCtrl =
        TextEditingController(text: '${existing?['address'] ?? ''}');
    final latCtrl = TextEditingController(
      text: existing?['latitude'] != null ? '${existing!['latitude']}' : '',
    );
    final lngCtrl = TextEditingController(
      text: existing?['longitude'] != null ? '${existing!['longitude']}' : '',
    );
    var status = '${existing?['status'] ?? 'ACTIVE'}';

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(existing == null ? 'Thêm garage' : 'Sửa garage'),
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
                        controller: addressCtrl,
                        decoration: const InputDecoration(labelText: 'Địa chỉ'),
                        maxLines: 2,
                      ),
                      TextField(
                        controller: latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                      TextField(
                        controller: lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: 'Longitude'),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        items: const [
                          DropdownMenuItem(
                            value: 'ACTIVE',
                            child: Text('ACTIVE'),
                          ),
                          DropdownMenuItem(
                            value: 'INACTIVE',
                            child: Text('INACTIVE'),
                          ),
                        ],
                        onChanged: (v) =>
                            setLocal(() => status = v ?? 'ACTIVE'),
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
      addressCtrl.dispose();
      latCtrl.dispose();
      lngCtrl.dispose();
      return;
    }

    final body = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'status': status,
    };

    final lat = double.tryParse(latCtrl.text.trim());
    final lng = double.tryParse(lngCtrl.text.trim());
    if (lat != null) body['latitude'] = lat;
    if (lng != null) body['longitude'] = lng;

    nameCtrl.dispose();
    addressCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();

    try {
      if (existing == null) {
        await _service.createGarage(body);
      } else {
        await _service.updateGarage(existing['id'] as int, body);
      }
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? 'Đã thêm garage' : 'Đã cập nhật garage',
          ),
        ),
      );
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

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa garage'),
        content: Text(
          'Xóa garage "${item['name']}" khỏi danh sách?\n'
          '(Không xóa khỏi DB — chỉ ẩn khỏi Admin và khách)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteGarage(item['id'] as int);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa garage khỏi danh sách')),
      );
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
        label: const Text('Thêm garage'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Chưa có garage')),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final g = _items[index];
                            final status = '${g['status'] ?? ''}'.toUpperCase();
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.store),
                                title: Text(
                                  '${g['name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${g['address'] ?? ''}\n'
                                  '${status.isEmpty ? '' : status}',
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Sửa',
                                      onPressed: () =>
                                          _openForm(existing: g),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        status == 'ACTIVE'
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        color: status == 'ACTIVE'
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      tooltip: 'Đổi trạng thái',
                                      onPressed: () => _toggleStatus(g),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Xóa',
                                      onPressed: () => _delete(g),
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

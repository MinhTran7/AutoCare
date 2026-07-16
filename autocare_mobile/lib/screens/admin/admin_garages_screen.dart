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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final g = _items[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(
                '${g['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${g['address'] ?? ''}\n${g['phone'] ?? ''} · ${g['status'] ?? ''}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

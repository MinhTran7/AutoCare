import 'package:flutter/material.dart';

import '../../services/admin_customer_service.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  final AdminCustomerService _service = AdminCustomerService();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  String _statusFilter = 'ALL';
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getCustomers();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final keyword = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((c) {
        final status = '${c['status'] ?? ''}'.toUpperCase();
        if (_statusFilter != 'ALL' && status != _statusFilter) return false;
        final hay = '${c['fullName']} ${c['email']} ${c['phone']}'.toLowerCase();
        return hay.contains(keyword);
      }).toList();
    });
  }

  Future<void> _lock(Map<String, dynamic> customer) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khóa khách hàng'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Lý do khóa',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              reasonController.text.trim().isEmpty
                  ? 'Admin đã khóa tài khoản'
                  : reasonController.text.trim(),
            ),
            child: const Text('Khóa'),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null) return;

    try {
      await _service.lockCustomer(customer['id'] as int, reason: reason);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã khóa khách hàng')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _unlock(Map<String, dynamic> customer) async {
    try {
      await _service.unlockCustomer(customer['id'] as int);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã mở khóa khách hàng')),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm tên / email / SĐT',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'LOCKED', child: Text('LOCKED')),
                  DropdownMenuItem(
                    value: 'PENDING_VERIFY',
                    child: Text('PENDING_VERIFY'),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _statusFilter = v ?? 'ALL');
                  _applyFilter();
                },
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_filtered.isEmpty) {
      return const Center(child: Text('Không có khách hàng'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final c = _filtered[index];
        final status = '${c['status'] ?? ''}'.toUpperCase();
        final locked = status == 'LOCKED';

        return Card(
          child: ListTile(
            title: Text(
              '${c['fullName'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${c['email']}\n${c['phone']}\n$status'
              '${c['lockedReason'] != null ? '\nLý do: ${c['lockedReason']}' : ''}',
            ),
            isThreeLine: true,
            trailing: locked
                ? TextButton(
                    onPressed: () => _unlock(c),
                    child: const Text('Mở khóa'),
                  )
                : TextButton(
                    onPressed: status == 'PENDING_VERIFY' ? null : () => _lock(c),
                    child: const Text('Khóa'),
                  ),
          ),
        );
      },
    );
  }
}

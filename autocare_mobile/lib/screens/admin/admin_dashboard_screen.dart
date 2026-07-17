import 'package:flutter/material.dart';

import '../../services/admin_dashboard_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenInventory;

  const AdminDashboardScreen({super.key, this.onOpenInventory});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDashboardService _service = AdminDashboardService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = {};
  int _rangeDays = 7;

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
      final to = DateTime.now();
      final from = to.subtract(Duration(days: _rangeDays - 1));
      final summary = await _service.getSummary(
        from: _formatDate(from),
        to: _formatDate(to),
      );
      if (!mounted) return;
      setState(() {
        _data = summary;
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

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final byStatus = Map<String, dynamic>.from(
      (_data['bookingsByStatus'] as Map?) ?? {},
    );
    final lowStockItems =
        (_data['lowStockItems'] as List?)?.cast<dynamic>() ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('7 ngày'),
                selected: _rangeDays == 7,
                onSelected: (_) {
                  setState(() => _rangeDays = 7);
                  _load();
                },
              ),
              ChoiceChip(
                label: const Text('30 ngày'),
                selected: _rangeDays == 30,
                onSelected: (_) {
                  setState(() => _rangeDays = 30);
                  _load();
                },
              ),
              ChoiceChip(
                label: const Text('Hôm nay'),
                selected: _rangeDays == 1,
                onSelected: (_) {
                  setState(() => _rangeDays = 1);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                title: 'Đơn trong kỳ',
                value: '${_data['totalBookingsInRange'] ?? 0}',
                icon: Icons.assignment,
                color: Colors.blue,
              ),
              _MetricCard(
                title: 'Ca HOME đang xử lý',
                value: '${_data['homeJobsInProgress'] ?? 0}',
                icon: Icons.home_repair_service,
                color: Colors.orange,
              ),
              _MetricCard(
                title: 'Doanh thu PAID',
                value: _formatMoney(_data['paidRevenue']),
                icon: Icons.payments,
                color: Colors.green,
              ),
              _MetricCard(
                title: 'Khách hàng',
                value: '${_data['totalCustomers'] ?? 0}',
                icon: Icons.people,
                color: Colors.indigo,
              ),
              _MetricCard(
                title: 'Thợ',
                value: '${_data['totalMechanics'] ?? 0}',
                icon: Icons.engineering,
                color: Colors.teal,
              ),
              _MetricCard(
                title: 'Kho sắp hết',
                value: '${_data['lowStockCount'] ?? 0}',
                icon: Icons.warning_amber,
                color: Colors.red,
                onTap: widget.onOpenInventory,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Đơn theo trạng thái',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...byStatus.entries.map((e) {
            final max = byStatus.values
                .map((v) => (v as num).toDouble())
                .fold<double>(1, (a, b) => a > b ? a : b);
            final value = (e.value as num).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.key}: ${e.value}'),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value / max,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            'Cảnh báo tồn kho thấp',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (lowStockItems.isEmpty)
            const Text('Không có phụ tùng dưới mức tối thiểu')
          else
            ...lowStockItems.map((raw) {
              final item = Map<String, dynamic>.from(raw as Map);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.red),
                  title: Text('${item['partName']}'),
                  subtitle: Text(
                    'Tồn: ${item['quantityInStock']} / Min: ${item['minStockLevel']}',
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatMoney(dynamic value) {
    if (value == null) return '0';
    final number = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

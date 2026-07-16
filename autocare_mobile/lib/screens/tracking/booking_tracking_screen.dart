import 'package:flutter/material.dart';
import '../../services/booking_status_service.dart';

class BookingTrackingScreen extends StatefulWidget {
  final int bookingId;
  const BookingTrackingScreen({super.key, required this.bookingId});

  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  final _service = BookingStatusService();
  List<Map<String, dynamic>> _timeline = [];
  bool _isLoading = true;

  final List<String> _steps = ['PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED'];
  final Map<String, String> _stepLabel = {
    'PENDING': 'Chờ xác nhận',
    'CONFIRMED': 'Đã xác nhận',
    'IN_PROGRESS': 'Đang sửa chữa',
    'COMPLETED': 'Hoàn thành',
    'CANCELLED': 'Đã huỷ',
  };
  final Map<String, IconData> _stepIcon = {
    'PENDING': Icons.access_time,
    'CONFIRMED': Icons.check_circle_outline,
    'IN_PROGRESS': Icons.build,
    'COMPLETED': Icons.verified,
    'CANCELLED': Icons.cancel,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getTimeline(widget.bookingId);
      setState(() => _timeline = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String get _currentStatus =>
      _timeline.isEmpty ? 'PENDING' : (_timeline.last['newStatus'] ?? 'PENDING');

  bool get _isCancelled => _currentStatus == 'CANCELLED';

  String _formatTime(String? raw) {
    if (raw == null || raw.length < 16) return raw ?? '';
    return raw.substring(0, 16).replaceFirst('T', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi lịch hẹn'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Trạng thái hiện tại
            Card(
              child: ListTile(
                leading: Icon(_stepIcon[_currentStatus] ?? Icons.info),
                title: const Text('Trạng thái hiện tại'),
                subtitle: Text(
                  _stepLabel[_currentStatus] ?? _currentStatus,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: _isCancelled
                    ? const Icon(Icons.cancel, color: Colors.red)
                    : const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),

            const SizedBox(height: 12),

            // Timeline Stepper
            if (!_isCancelled) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiến trình',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._steps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        final currentIndex = _steps.indexOf(_currentStatus);
                        final isDone = index <= currentIndex;
                        final isActive = index == currentIndex;
                        final isLast = index == _steps.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isDone
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  child: Icon(
                                    isDone ? Icons.check : _stepIcon[step],
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 36,
                                    color: index < currentIndex
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _stepLabel[step] ?? step,
                                      style: TextStyle(
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isDone
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (isActive)
                                      Text(
                                        'Hiện tại',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    if (!isLast) const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Lịch sử hoạt động
            if (_timeline.isNotEmpty) ...[
              const Text(
                'Lịch sử hoạt động',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._timeline.reversed.map((log) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(_stepIcon[log['newStatus']] ?? Icons.info),
                  title: Text(_stepLabel[log['newStatus']] ?? log['newStatus'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log['note'] != null && log['note'].toString().isNotEmpty)
                        Text(log['note']),
                      Text(
                        _formatTime(log['changedAt']),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: log['note'] != null && log['note'].toString().isNotEmpty,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
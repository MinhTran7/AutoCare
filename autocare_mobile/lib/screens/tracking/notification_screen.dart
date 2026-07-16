import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _service = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAll();
      setState(() => _notifications = data);
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

  Future<void> _markAsRead(int id) async {
    await _service.markAsRead(id);
    setState(() {
      final i = _notifications.indexWhere((n) => n['id'] == id);
      if (i != -1) _notifications[i]['isRead'] = true;
    });
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllAsRead();
    setState(() {
      for (final n in _notifications) n['isRead'] = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
      );
    }
  }

  Future<void> _delete(int id) async {
    await _service.delete(id);
    setState(() => _notifications.removeWhere((n) => n['id'] == id));
  }

  // Điều hướng theo type + bookingId
  void _navigate(Map<String, dynamic> notification) {
    final type = notification['type'];
    final bookingId = notification['bookingId'];

    // Đánh dấu đã đọc trước
    _markAsRead(notification['id']);

    // Nếu không có bookingId → không điều hướng
    if (bookingId == null) return;

    switch (type) {
      case 'booking_confirmed':
      case 'status_update':
        Navigator.pushNamed(
          context,
          '/booking-tracking',
          arguments: {'bookingId': bookingId},
        );
        break;
      case 'invoice_ready':
        Navigator.pushNamed(
          context,
          '/invoice',
          arguments: {'bookingId': bookingId},
        );
        break;
      case 'review_reminder':
      // review cần thêm garageId + garageName
      // Tạm thời điều hướng về tracking, khi TV2 có data thì cập nhật
        Navigator.pushNamed(
          context,
          '/booking-tracking',
          arguments: {'bookingId': bookingId},
        );
        break;
      default:
      // promo hoặc type khác → không điều hướng
        break;
    }
  }

  int get _unreadCount => _notifications.where((n) => n['isRead'] == false).length;

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'booking_confirmed': return Icons.check_circle;
      case 'status_update': return Icons.update;
      case 'invoice_ready': return Icons.receipt_long;
      case 'review_reminder': return Icons.star;
      case 'promo': return Icons.local_offer;
      default: return Icons.notifications;
    }
  }

  // Nhãn loại thông báo hiển thị nhỏ dưới tiêu đề
  String _typeLabel(String? type) {
    switch (type) {
      case 'booking_confirmed': return 'Xác nhận lịch hẹn';
      case 'status_update': return 'Cập nhật trạng thái';
      case 'invoice_ready': return 'Hoá đơn sẵn sàng';
      case 'review_reminder': return 'Nhắc đánh giá';
      case 'promo': return 'Khuyến mãi';
      default: return '';
    }
  }

  // Có thể điều hướng không
  bool _isNavigable(String? type) {
    return ['booking_confirmed', 'status_update', 'invoice_ready', 'review_reminder']
        .contains(type);
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.length < 16) return raw ?? '';
    return raw.substring(0, 16).replaceFirst('T', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thông báo'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Đọc tất cả'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có thông báo nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final n = _notifications[index];
            final isRead = n['isRead'] == true;
            final canNavigate = _isNavigable(n['type']) && n['bookingId'] != null;

            return Dismissible(
              key: Key('notif-${n['id']}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _delete(n['id']),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isRead ? null : Colors.blue.shade50,
                child: ListTile(
                  leading: Icon(
                    _typeIcon(n['type']),
                    color: isRead
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    n['title'] ?? '',
                    style: TextStyle(
                      fontWeight: isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n['body'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTime(n['createdAt']),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          if (_typeLabel(n['type']).isNotEmpty) ...[
                            const Text(
                              ' · ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _typeLabel(n['type']),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  // Mũi tên nếu có thể điều hướng
                  trailing: canNavigate
                      ? const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  )
                      : isRead
                      ? null
                      : CircleAvatar(
                    radius: 5,
                    backgroundColor:
                    Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _navigate(n),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
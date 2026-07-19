import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../storage/token_storage.dart';

/// ---------------------------------------------------------------------
/// Design tokens — tuned for a customer-facing garage/repair booking app.
/// Deep charcoal-navy reads as "trustworthy workshop"; warm amber is the
/// single accent used only for primary actions and the ticket stamp, so
/// it keeps its weight as a call to action.
/// ---------------------------------------------------------------------
class _Palette {
  static const bg = Color(0xFFF6F7FA);
  static const ink = Color(0xFF1E2733); // deep charcoal-navy
  static const inkSoft = Color(0xFF64748B);
  static const accent = Color(0xFFF08A24); // warm amber — primary actions only
  static const accentDark = Color(0xFFD9720F);
  static const divider = Color(0xFFE7EAEE);
  static const cardBg = Colors.white;
}

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchMyBookings();
  }

  Future<void> _refresh() async {
    final next = _fetchMyBookings();
    setState(() => _bookingsFuture = next);
    // Let the RefreshIndicator spinner stay visible until the request settles,
    // and surface any error through the same FutureBuilder error branch.
    await next.catchError((_) => <Map<String, dynamic>>[]);
  }

  Future<List<Map<String, dynamic>>> _fetchMyBookings() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/bookings/my-bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data as List);
    }
    throw Exception('Lỗi server: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _Palette.ink,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _Palette.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.build_rounded, color: _Palette.accentDark, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lịch hẹn của bạn',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, height: 1.1),
                ),
                Text(
                  'Theo dõi tình trạng xe của bạn',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: _Palette.inkSoft),
                ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _Palette.accent),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _refresh,
            );
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return RefreshIndicator(
              color: _Palette.accent,
              onRefresh: _refresh,
              child: const _EmptyState(),
            );
          }

          return RefreshIndicator(
            color: _Palette.accent,
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: bookings.length,
              itemBuilder: (context, index) => _BookingTicketCard(booking: bookings[index]),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// The signature element: each booking renders as a physical-feeling
/// "service ticket" — header + progress stamp + perforated tear line +
/// details + actions — echoing the paper claim ticket a real garage
/// hands a customer, rather than a generic dashboard row.
/// ---------------------------------------------------------------------
class _BookingTicketCard extends StatelessWidget {
  const _BookingTicketCard({required this.booking});

  final Map<String, dynamic> booking;

  static const _statusOrder = ['PENDING', 'CONFIRMED', 'COMPLETED'];

  @override
  Widget build(BuildContext context) {
    final bId = booking['id'];
    final bIdLabel = bId == null ? '—' : '#$bId';
    final rawStatus = (booking['status'] as String?)?.toUpperCase() ?? 'PENDING';
    final serviceName = (booking['serviceName'] as String?)?.trim();
    final garageName = (booking['garageName'] as String?)?.trim();
    final isCompleted = rawStatus == 'COMPLETED';
    final isCancelled = rawStatus == 'CANCELLED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _Palette.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _Palette.ink.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_num_outlined, size: 16, color: _Palette.inkSoft),
                    const SizedBox(width: 6),
                    Text(
                      'Mã đơn $bIdLabel',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.2,
                        color: _Palette.inkSoft,
                      ),
                    ),
                  ],
                ),
                _StatusChip(status: rawStatus),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _Palette.accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_car_filled_rounded, color: _Palette.accentDark, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (serviceName == null || serviceName.isEmpty) ? 'Dịch vụ' : serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: _Palette.ink),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 14, color: _Palette.inkSoft),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (garageName == null || garageName.isEmpty) ? 'Garage AutoCare' : garageName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: _Palette.inkSoft),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isCancelled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 15, color: Color(0xFFB3261E)),
                  SizedBox(width: 6),
                  Text('Lịch hẹn đã bị huỷ', style: TextStyle(fontSize: 12.5, color: Color(0xFFB3261E), fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _ProgressStepper(currentStatus: rawStatus, steps: _statusOrder),
            ),
          const SizedBox(height: 16),
          _TicketTearLine(color: _Palette.bg),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _Palette.ink,
                          side: const BorderSide(color: _Palette.divider),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.receipt_long_outlined, size: 16),
                        label: const Text('Hoá đơn'),
                        onPressed: () => Navigator.pushNamed(context, '/invoice', arguments: {'bookingId': bId}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? _Palette.bg : _Palette.ink,
                          foregroundColor: isCompleted ? _Palette.inkSoft : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.track_changes_outlined, size: 16),
                        label: const Text('Tiến trình'),
                        onPressed: () => Navigator.pushNamed(context, '/booking-tracking', arguments: {'bookingId': bId}),
                      ),
                    ),
                  ],
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Palette.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.star_rounded, size: 18),
                      label: const Text('Gửi đánh giá dịch vụ', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/review', arguments: {
                          'bookingId': bId,
                          'serviceId': booking['serviceId'],
                          'garageId': booking['garageId'],
                          'garageName': garageName,
                          'status': rawStatus,
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  static const _labels = {
    'COMPLETED': 'Hoàn thành',
    'CONFIRMED': 'Đã xác nhận',
    'PENDING': 'Chờ xử lý',
    'CANCELLED': 'Đã huỷ',
  };

  static const _colors = {
    'COMPLETED': Color(0xFF2E7D5B),
    'CONFIRMED': Color(0xFF2563EB),
    'PENDING': Color(0xFFB8720A),
    'CANCELLED': Color(0xFFB3261E),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? _Palette.inkSoft;
    final label = _labels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Small progress stepper — "structure as information": for a booking
/// that is genuinely a sequence (pending → confirmed → completed), the
/// stepper tells the customer exactly where their car is right now.
class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.currentStatus, required this.steps});
  final String currentStatus;
  final List<String> steps;

  static const _stepLabels = {
    'PENDING': 'Đặt lịch',
    'CONFIRMED': 'Xác nhận',
    'COMPLETED': 'Hoàn thành',
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = steps.indexOf(currentStatus);
    final activeIndex = currentIndex == -1 ? 0 : currentIndex;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftStepDone = (i ~/ 2) < activeIndex;
          return Expanded(
            child: Container(height: 2, color: leftStepDone ? _Palette.accent : _Palette.divider),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex < activeIndex;
        final active = stepIndex == activeIndex;
        final color = (done || active) ? _Palette.accent : _Palette.divider;
        return Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? _Palette.accent : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : (active ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: _Palette.accent, shape: BoxShape.circle))) : null),
            ),
            const SizedBox(height: 4),
            Text(
              _stepLabels[steps[stepIndex]] ?? steps[stepIndex],
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: (done || active) ? _Palette.ink : _Palette.inkSoft,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// The ticket "tear line" — a dashed rule with side notches cut into the
/// card, mimicking the perforation on a real garage service ticket.
class _TicketTearLine extends StatelessWidget {
  const _TicketTearLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CustomPaint(painter: _DashedLinePainter(), size: const Size(double.infinity, 1)),
          Positioned(left: -8, child: _notch()),
          Positioned(right: -8, child: _notch()),
        ],
      ),
    );
  }

  Widget _notch() => Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _Palette.divider
      ..strokeWidth = 1.4;
    const dashWidth = 5.0;
    const dashGap = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dashWidth, size.width), y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(color: _Palette.accent.withOpacity(0.10), shape: BoxShape.circle),
                    child: const Icon(Icons.event_available_outlined, size: 38, color: _Palette.accentDark),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chưa có lịch hẹn nào',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _Palette.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đặt lịch sửa xe đầu tiên để bắt đầu theo dõi\ntình trạng xe của bạn tại đây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: _Palette.inkSoft, height: 1.4),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Palette.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Đặt lịch ngay', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.pushNamed(context, '/booking'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: Color(0x14B3261E), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFFB3261E)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không thể tải lịch hẹn',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _Palette.ink),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: _Palette.inkSoft, height: 1.4),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _Palette.ink,
                side: const BorderSide(color: _Palette.divider),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
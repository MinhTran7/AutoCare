import 'package:flutter/material.dart';
import '../../services/invoice_service.dart';

class InvoiceScreen extends StatefulWidget {
  final int bookingId;
  const InvoiceScreen({super.key, required this.bookingId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _service = InvoiceService();
  Map<String, dynamic>? _invoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getByBookingId(widget.bookingId);
      setState(() => _invoice = data);
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

  String _formatMoney(dynamic value) {
    if (value == null) return '0 đ';
    final num = double.tryParse(value.toString()) ?? 0;
    return '${num.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')} đ';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.length < 16) return raw ?? '—';
    return raw.substring(0, 16).replaceFirst('T', ' ');
  }

  String get _statusLabel {
    switch (_invoice?['status']) {
      case 'PAID': return 'Đã thanh toán';
      case 'CANCELLED': return 'Đã huỷ';
      default: return 'Chưa thanh toán';
    }
  }

  Future<void> _handlePay(String method) async {
    try {
      setState(() => _isLoading = true);
      await _service.markAsPaid(widget.bookingId, method);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thành công!')),
        );
      }
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

  void _showPaymentDialog() {
    final methods = {
      'CASH': '💵 Tiền mặt',
      'BANKING': '🏦 Chuyển khoản',
      'MOMO': '💜 MoMo',
      'VNPAY': '🔵 VNPay',
      'ZALOPAY': '🟦 ZaloPay',
    };

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chọn phương thức thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...methods.entries.map((e) => ListTile(
            title: Text(e.value),
            onTap: () {
              Navigator.pop(ctx);
              _handlePay(e.key);
            },
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoá đơn')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoice == null
          ? const Center(child: Text('Chưa có hoá đơn cho lịch hẹn này'))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Mã hoá đơn + trạng thái
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(_invoice!['invoiceCode'] ?? 'N/A'),
                subtitle: Text('Booking #${widget.bookingId}'),
                trailing: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _invoice!['status'] == 'PAID'
                        ? Colors.green
                        : _invoice!['status'] == 'CANCELLED'
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chi tiết tiền
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildRow('Tạm tính', _formatMoney(_invoice!['subtotal'])),
                    _buildRow('Giảm giá', _formatMoney(_invoice!['discount'])),
                    _buildRow('Thuế VAT', _formatMoney(_invoice!['taxAmount'])),
                    const Divider(),
                    _buildRow(
                      'Tổng cộng',
                      _formatMoney(_invoice!['totalAmount']),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Thông tin thanh toán
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Phương thức'),
                    subtitle: Text(_invoice!['paymentMethod'] ?? '—'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Ngày tạo'),
                    subtitle: Text(_formatDate(_invoice!['createdAt'])),
                  ),
                  if (_invoice!['paidAt'] != null)
                    ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: const Text('Đã thanh toán lúc'),
                      subtitle: Text(_formatDate(_invoice!['paidAt'])),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút thanh toán
            if (_invoice!['status'] == 'UNPAID')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showPaymentDialog,
                  icon: const Icon(Icons.payment),
                  label: const Text('Thanh toán ngay'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
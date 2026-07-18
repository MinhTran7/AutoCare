import 'package:flutter/material.dart';
import '../../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final int bookingId;
  final int garageId;
  final String garageName;
  final String status;

  const ReviewScreen({super.key, required this.bookingId, required this.garageId, required this.garageName, required this.status});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _service = ReviewService();
  final _commentController = TextEditingController();
  Map<String, dynamic>? _existingReview;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _garageReviews = []; // MỚI: toàn bộ review của garage
  String _filter = 'Tất cả';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    Map<String, dynamic>? review;
    List<Map<String, dynamic>> services = [];
    List<Map<String, dynamic>> garageReviews = [];

    try {
      review = await _service.getByBookingId(widget.bookingId);
    } catch (e) {
      debugPrint('Lỗi getByBookingId: $e');
    }

    try {
      services = await _service.getAllServices();
    } catch (e) {
      debugPrint('Lỗi getAllServices: $e');
    }

    try {
      garageReviews = await _service.getReviewsByGarage(widget.garageId);
    } catch (e) {
      debugPrint('Lỗi getReviewsByGarage: $e');
    }

    if (!mounted) return;
    setState(() {
      _existingReview = review;
      _services = services;
      _garageReviews = garageReviews;
      if (review != null) {
        _selectedRating = review['rating'] ?? 0;
        _commentController.text = review['comment'] ?? '';
      }
      _isLoading = false;
    });
  }

  // MỚI: danh sách review sau khi lọc theo dropdown
  List<Map<String, dynamic>> get _filteredReviews {
    if (_filter == 'Tất cả') return _garageReviews;
    return _garageReviews.where((r) => r['serviceName'] == _filter).toList();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      if (_existingReview != null) {
        final updated = await _service.updateReview(bookingId: widget.bookingId, rating: _selectedRating, comment: _commentController.text.trim());
        setState(() { _existingReview = updated; _isEditing = false; });
      } else {
        final created = await _service.createReview(bookingId: widget.bookingId, garageId: widget.garageId, rating: _selectedRating, comment: _commentController.text.trim());
        setState(() => _existingReview = created);
      }
      // Sau khi gửi/sửa xong, tải lại danh sách để nó xuất hiện trong list lọc
      await _loadData();
    } catch (e) {
      debugPrint('Lỗi khi gửi đánh giá: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi đánh giá thất bại: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => IconButton(
            icon: Icon(index < _selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
            onPressed: () => setState(() => _selectedRating = index + 1),
          )),
        ),
        TextField(controller: _commentController, decoration: const InputDecoration(labelText: 'Nhận xét của bạn')),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_existingReview == null ? 'Gửi đánh giá' : 'Cập nhật'),
        ),
      ],
    );
  }

  Widget _buildExistingReview() {
    final rating = _existingReview!['rating'] ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đánh giá của bạn', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 32))),
            Text(_existingReview!['comment'] ?? ''),
            Align(alignment: Alignment.centerRight, child: IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => setState(() => _isEditing = true))),
          ],
        ),
      ),
    );
  }

  // MỚI: danh sách các review khác của garage, đã lọc theo dropdown
  Widget _buildReviewList() {
    if (_filteredReviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Chưa có đánh giá nào cho dịch vụ này.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      children: _filteredReviews.map((r) {
        final rating = r['rating'] ?? 0;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['serviceName']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18))),
                Text(r['comment']?.toString() ?? ''),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá dịch vụ')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            value: _services.any((s) => s['name'] == _filter) || _filter == 'Tất cả' ? _filter : 'Tất cả',
            isExpanded: true,
            hint: const Text('Chọn dịch vụ'),
            items: [
              const DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
              ..._services.map((s) => DropdownMenuItem<String>(
                value: s['name'].toString(),
                child: Text(s['name'].toString()),
              )),
            ],
            onChanged: (val) => setState(() => _filter = val!),
          ),
          const SizedBox(height: 8),
          // MỚI: danh sách review đã lọc
          _buildReviewList(),
          const Divider(height: 32),
          if (widget.status == 'COMPLETED') ...[
            Text(_existingReview == null ? 'Gửi đánh giá' : 'Đánh giá của bạn', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_existingReview == null || _isEditing) _buildForm() else _buildExistingReview(),
          ] else const Center(child: Text("Đơn hàng chưa hoàn thành")),
        ],
      ),
    );
  }
}
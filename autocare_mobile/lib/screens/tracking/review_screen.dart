import 'package:flutter/material.dart';
import '../../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final int bookingId;
  final int garageId;
  final String garageName;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.garageId,
    required this.garageName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _service = ReviewService();
  final _commentController = TextEditingController();

  Map<String, dynamic>? _existingReview;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final review = await _service.getByBookingId(widget.bookingId);
      setState(() {
        _existingReview = review;
        if (review != null) {
          _selectedRating = review['rating'] ?? 5;
          _commentController.text = review['comment'] ?? '';
        }
      });
    } catch (_) {
      // Chưa có review → bình thường
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      if (_existingReview != null) {
        final updated = await _service.updateReview(
          bookingId: widget.bookingId,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
        );
        setState(() {
          _existingReview = updated;
          _isEditing = false;
        });
      } else {
        final created = await _service.createReview(
          bookingId: widget.bookingId,
          garageId: widget.garageId,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
        );
        setState(() => _existingReview = created);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingReview != null
                ? 'Cập nhật đánh giá thành công!'
                : 'Gửi đánh giá thành công!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá đánh giá'),
        content: const Text('Bạn có chắc muốn xoá đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.deleteReview(widget.bookingId);
      setState(() {
        _existingReview = null;
        _selectedRating = 5;
        _commentController.clear();
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá đánh giá')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Xuất sắc!';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá dịch vụ'),
        actions: [
          if (_existingReview != null && !_isEditing)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') setState(() => _isEditing = true);
                if (value == 'delete') _delete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Sửa đánh giá'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xoá', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thông tin garage
          Card(
            child: ListTile(
              leading: const Icon(Icons.garage),
              title: Text(widget.garageName),
              subtitle: Text('Booking #${widget.bookingId}'),
            ),
          ),

          const SizedBox(height: 12),

          // Hiện form khi chưa có review hoặc đang edit
          if (_existingReview == null || _isEditing)
            _buildForm()
          else
            _buildExistingReview(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Sửa đánh giá' : 'Đánh giá của bạn',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Sao
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = star),
                        child: Icon(
                          star <= _selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 48,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ratingLabel(_selectedRating),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Comment
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                if (_isEditing) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _selectedRating = _existingReview!['rating'] ?? 5;
                          _commentController.text = _existingReview!['comment'] ?? '';
                        });
                      },
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(_isEditing ? 'Cập nhật' : 'Gửi đánh giá'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingReview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá của bạn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Sao
            Row(
              children: List.generate(5, (index) {
                final star = index + 1;
                return Icon(
                  star <= (_existingReview!['rating'] ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 28,
                );
              }),
            ),

            const SizedBox(height: 8),

            if (_existingReview!['comment'] != null &&
                _existingReview!['comment'].toString().isNotEmpty)
              Text(
                _existingReview!['comment'],
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 8),

            Text(
              'Đánh giá lúc: ${_existingReview!['createdAt']?.toString().substring(0, 10) ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/review_service.dart';

/// ---------------------------------------------------------------------
/// Shared with my_bookings_screen.dart. If both screens keep drifting in
/// tandem, consider pulling this into lib/theme/app_palette.dart so the
/// two never fall out of sync.
/// ---------------------------------------------------------------------
class _Palette {
  static const bg = Color(0xFFF6F7FA);
  static const ink = Color(0xFF1E2733);
  static const inkSoft = Color(0xFF64748B);
  static const accent = Color(0xFFF08A24);
  static const accentDark = Color(0xFFD9720F);
  static const divider = Color(0xFFE7EAEE);
  static const cardBg = Colors.white;
}

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
  List<Map<String, dynamic>> _garageReviews = [];
  String _filter = 'Tất cả';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  int _selectedRating = 0;

  bool get _isCompleted => widget.status.toUpperCase() == 'COMPLETED';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    debugPrint('===> garageId đang dùng để tải review = ${widget.garageId}');
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
      debugPrint('===> Kết quả getReviewsByGarage: $garageReviews');
    } catch (e) {
      debugPrint('Lỗi getReviewsByGarage: $e');
    }

    if (!mounted) return;
    setState(() {
      _existingReview = review;
      _services = services;
      _garageReviews = garageReviews;
      // Bug fix: if the previously selected filter no longer matches any
      // known service name, reset the *state* too — not just the
      // dropdown's displayed value — so the filtered list and the
      // dropdown never disagree with each other.
      if (_filter != 'Tất cả' && !_services.any((s) => s['name'] == _filter)) {
        _filter = 'Tất cả';
      }
      if (review != null) {
        _selectedRating = review['rating'] ?? 0;
        _commentController.text = review['comment'] ?? '';
      }
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredReviews {
    if (_filter == 'Tất cả') return _garageReviews;
    return _garageReviews.where((r) {
      final names = (r['serviceNames'] as List?)?.cast<String>() ?? [];
      return names.contains(_filter);
    }).toList();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    // Bug fix: don't allow submitting with no star selected.
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao trước khi gửi đánh giá')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      if (_existingReview != null) {
        final updated = await _service.updateReview(bookingId: widget.bookingId, rating: _selectedRating, comment: _commentController.text.trim());
        setState(() {
          _existingReview = updated;
          _isEditing = false;
        });
      } else {
        final created = await _service.createReview(bookingId: widget.bookingId, garageId: widget.garageId, rating: _selectedRating, comment: _commentController.text.trim());
        setState(() => _existingReview = created);
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cảm ơn bạn đã gửi đánh giá!')),
        );
      }
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

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Restore the form fields to the saved review instead of leaving
      // whatever the user was mid-typing.
      _selectedRating = _existingReview?['rating'] ?? 0;
      _commentController.text = _existingReview?['comment'] ?? '';
    });
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Đánh giá dịch vụ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, height: 1.1)),
            Text(widget.garageName, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: _Palette.inkSoft)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _Palette.accent))
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_isCompleted) ...[
            _RateCard(
              existingReview: _existingReview,
              isEditing: _isEditing,
              isSaving: _isSaving,
              selectedRating: _selectedRating,
              commentController: _commentController,
              onRatingChanged: (r) => setState(() => _selectedRating = r),
              onSubmit: _submit,
              onStartEdit: () => setState(() => _isEditing = true),
              onCancelEdit: _cancelEditing,
            ),
            const SizedBox(height: 24),
          ] else
            const _PendingCompletionNotice(),
          Row(
            children: [
              const Icon(Icons.forum_outlined, size: 18, color: _Palette.ink),
              const SizedBox(width: 8),
              const Text('Đánh giá từ khách hàng khác', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _Palette.ink)),
              const Spacer(),
              Text('${_garageReviews.length}', style: const TextStyle(fontSize: 13, color: _Palette.inkSoft, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _ServiceFilterDropdown(
            services: _services,
            selected: _filter,
            onSelected: (val) => setState(() => _filter = val),
          ),
          const SizedBox(height: 12),
          _ReviewList(reviews: _filteredReviews),
        ],
      ),
    );
  }
}

class _PendingCompletionNotice extends StatelessWidget {
  const _PendingCompletionNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Palette.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Palette.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _Palette.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.hourglass_bottom_rounded, size: 20, color: _Palette.accentDark),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Bạn có thể đánh giá sau khi dịch vụ hoàn tất.',
              style: TextStyle(fontSize: 13.5, color: _Palette.inkSoft, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card that holds either the "leave a rating" form or the customer's
/// already-submitted review, matching the ticket-card language used on
/// the bookings list (white card, soft shadow, amber accent).
class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.existingReview,
    required this.isEditing,
    required this.isSaving,
    required this.selectedRating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.onStartEdit,
    required this.onCancelEdit,
  });

  final Map<String, dynamic>? existingReview;
  final bool isEditing;
  final bool isSaving;
  final int selectedRating;
  final TextEditingController commentController;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;

  @override
  Widget build(BuildContext context) {
    final showForm = existingReview == null || isEditing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _Palette.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: _Palette.ink.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showForm ? (existingReview == null ? 'Gửi đánh giá của bạn' : 'Chỉnh sửa đánh giá') : 'Đánh giá của bạn',
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: _Palette.ink),
              ),
              if (!showForm)
                TextButton.icon(
                  onPressed: onStartEdit,
                  style: TextButton.styleFrom(foregroundColor: _Palette.accentDark, padding: EdgeInsets.zero, minimumSize: Size.zero),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Sửa'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (showForm) ...[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) => IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _Palette.accent,
                      size: 34,
                    ),
                    onPressed: () => onRatingChanged(index + 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Nhận xét của bạn (không bắt buộc)',
                filled: true,
                fillColor: _Palette.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (existingReview != null && isEditing) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSaving ? null : onCancelEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _Palette.ink,
                        side: const BorderSide(color: _Palette.divider),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Palette.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(existingReview == null ? 'Gửi đánh giá' : 'Cập nhật', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: List.generate(
                5,
                    (index) => Icon(index < (existingReview!['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded, color: _Palette.accent, size: 26),
              ),
            ),
            if ((existingReview!['comment'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(existingReview!['comment'].toString(), style: const TextStyle(fontSize: 14, color: _Palette.ink, height: 1.4)),
            ],
          ],
        ],
      ),
    );
  }
}

class _ServiceFilterDropdown extends StatelessWidget {
  const _ServiceFilterDropdown({required this.services, required this.selected, required this.onSelected});

  final List<Map<String, dynamic>> services;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final names = ['Tất cả', ...services.map((s) => s['name'].toString())];
    // Defensive: if `selected` somehow isn't in the list (e.g. a service
    // was renamed after the filter was set), fall back to 'Tất cả'
    // instead of crashing the DropdownButton's value assertion.
    final value = names.contains(selected) ? selected : 'Tất cả';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _Palette.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Palette.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: _Palette.inkSoft),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _Palette.ink),
          borderRadius: BorderRadius.circular(12),
          items: names
              .map((name) => DropdownMenuItem<String>(
            value: name,
            child: Text(name, overflow: TextOverflow.ellipsis),
          ))
              .toList(),
          onChanged: (val) => onSelected(val ?? 'Tất cả'),
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.reviews});
  final List<Map<String, dynamic>> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        alignment: Alignment.center,
        child: const Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 30, color: _Palette.inkSoft),
            SizedBox(height: 10),
            Text('Chưa có đánh giá nào cho dịch vụ này', style: TextStyle(color: _Palette.inkSoft, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: reviews.map((r) {
        final rating = r['rating'] ?? 0;
        final names = (r['serviceNames'] as List?)?.cast<String>() ?? [];
        final comment = r['comment']?.toString() ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _Palette.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Palette.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      names.isNotEmpty ? names.join(', ') : 'Dịch vụ khác',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: _Palette.ink),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: _Palette.accent, size: 15)),
                  ),
                ],
              ),
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(comment, style: const TextStyle(fontSize: 13, color: _Palette.inkSoft, height: 1.4)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
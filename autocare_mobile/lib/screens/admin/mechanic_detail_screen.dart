import 'package:flutter/material.dart';

class MechanicDetailScreen extends StatefulWidget {
  const MechanicDetailScreen({super.key});

  @override
  State<MechanicDetailScreen> createState() => _MechanicDetailScreenState();
}

class _MechanicDetailScreenState extends State<MechanicDetailScreen> {
  Map<String, dynamic>? _mechanic;
  bool _hasInitData = false;
  bool _hasUpdated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasInitData) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _mechanic = Map<String, dynamic>.from(args);
    }

    _hasInitData = true;
  }

  String _getText(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value == null) return '';

    return value.toString();
  }

  String _getDisplayValue(String value) {
    return value.trim().isEmpty ? 'Chưa có' : value;
  }

  bool _isActive(Map<String, dynamic> mechanic) {
    final status = _getText(mechanic, 'status').toUpperCase();

    return status == 'ACTIVE';
  }

  Future<void> _goToEditMechanic() async {
    final mechanic = _mechanic;

    if (mechanic == null) return;

    final result = await Navigator.pushNamed(
      context,
      '/edit-mechanic',
      arguments: mechanic,
    );

    if (result is Map<String, dynamic>) {
      setState(() {
        _mechanic = Map<String, dynamic>.from(result);
        _hasUpdated = true;
      });
    }
  }

  void _goBack() {
    Navigator.pop(context, _hasUpdated);
  }

  Widget _buildAvatar(Map<String, dynamic> mechanic) {
    final avatarUrl = _getText(mechanic, 'avatarUrl');
    final fullName = _getText(mechanic, 'fullName');

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    final firstChar = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'T';

    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.blue.shade100,
      child: Text(
        firstChar,
        style: const TextStyle(
          fontSize: 34,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? Colors.green : Colors.red,
        ),
      ),
      child: Text(
        active ? 'ON - Đang hoạt động' : 'OFF - Đã khóa',
        style: TextStyle(
          color: active ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _getDisplayValue(value),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mechanic = _mechanic;

    if (mechanic == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết thợ'),
        ),
        body: const Center(
          child: Text('Không có dữ liệu thợ'),
        ),
      );
    }

    final active = _isActive(mechanic);

    final lockedReason = _getText(mechanic, 'lockedReason').isNotEmpty
        ? _getText(mechanic, 'lockedReason')
        : _getText(mechanic, 'locked_reason');

    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff5f7fb),
        appBar: AppBar(
          title: const Text('Chi tiết thợ'),
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: _goToEditMechanic,
              icon: const Icon(Icons.edit),
              tooltip: 'Sửa thông tin',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: _buildAvatar(mechanic),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                _getDisplayValue(_getText(mechanic, 'fullName')),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: _buildStatusChip(active),
            ),

            const SizedBox(height: 24),

            _infoRow('Họ tên', _getText(mechanic, 'fullName')),
            _infoRow('Email', _getText(mechanic, 'email')),
            _infoRow('Số điện thoại', _getText(mechanic, 'phone')),
            _infoRow('Địa chỉ', _getText(mechanic, 'address')),
            _infoRow('Vai trò', _getText(mechanic, 'role')),
            _infoRow('Trạng thái', _getText(mechanic, 'status')),

            if (!active) _infoRow('Lý do khóa', lockedReason),

            _infoRow('Ngày tạo', _getText(mechanic, 'createdAt')),
            _infoRow('Ngày cập nhật', _getText(mechanic, 'updatedAt')),

            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _goToEditMechanic,
                icon: const Icon(Icons.edit),
                label: const Text('Sửa thông tin thợ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/admin_mechanic_service.dart';

class ManageMechanicsScreen extends StatefulWidget {
  final bool embedded;

  const ManageMechanicsScreen({super.key, this.embedded = false});

  @override
  State<ManageMechanicsScreen> createState() => _ManageMechanicsScreenState();
}

class _ManageMechanicsScreenState extends State<ManageMechanicsScreen> {
  final AdminMechanicService _service = AdminMechanicService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  String? _errorMessage;

  List<dynamic> _allMechanics = [];
  List<dynamic> _filteredMechanics = [];

  @override
  void initState() {
    super.initState();
    _loadMechanics();
    _searchController.addListener(_filterMechanics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMechanics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mechanics = await _service.getMechanics();

      if (!mounted) return;

      setState(() {
        _allMechanics = mechanics;
        _filteredMechanics = mechanics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterMechanics() {
    final keyword = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredMechanics = _allMechanics.where((item) {
        final mechanic = item as Map<String, dynamic>;

        final fullName = _getText(mechanic, 'fullName').toLowerCase();
        final email = _getText(mechanic, 'email').toLowerCase();
        final phone = _getText(mechanic, 'phone').toLowerCase();

        return fullName.contains(keyword) ||
            email.contains(keyword) ||
            phone.contains(keyword);
      }).toList();
    });
  }

  void _replaceMechanicInList(Map<String, dynamic> updatedMechanic) {
    final updatedId = updatedMechanic['id'];

    if (updatedId == null) {
      _loadMechanics();
      return;
    }

    final keyword = _searchController.text.trim().toLowerCase();

    setState(() {
      _allMechanics = _allMechanics.map((item) {
        final mechanic = item as Map<String, dynamic>;

        if (mechanic['id'].toString() == updatedId.toString()) {
          return updatedMechanic;
        }

        return mechanic;
      }).toList();

      _filteredMechanics = _allMechanics.where((item) {
        final mechanic = item as Map<String, dynamic>;

        final fullName = _getText(mechanic, 'fullName').toLowerCase();
        final email = _getText(mechanic, 'email').toLowerCase();
        final phone = _getText(mechanic, 'phone').toLowerCase();

        return fullName.contains(keyword) ||
            email.contains(keyword) ||
            phone.contains(keyword);
      }).toList();
    });
  }

  String _getText(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value == null) return '';

    return value.toString();
  }

  int _getId(Map<String, dynamic> mechanic) {
    final value = mechanic['id'];

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  bool _isActive(Map<String, dynamic> mechanic) {
    final status = _getText(mechanic, 'status').toUpperCase();

    return status == 'ACTIVE';
  }

  Future<void> _openCreateMechanicScreen() async {
    final result = await Navigator.pushNamed(context, '/create-mechanic');

    if (result == true) {
      _loadMechanics();
    }
  }

  Future<void> _openMechanicDetailScreen(
      Map<String, dynamic> mechanic,
      ) async {
    final result = await Navigator.pushNamed(
      context,
      '/mechanic-detail',
      arguments: mechanic,
    );

    if (result == true) {
      _loadMechanics();
    }
  }

  Future<void> _toggleMechanicStatus(
      Map<String, dynamic> mechanic,
      bool newValue,
      ) async {
    if (_isUpdatingStatus) return;

    final mechanicId = _getId(mechanic);
    final fullName = _getText(mechanic, 'fullName');

    if (mechanicId == 0) {
      _showError('Không xác định được ID thợ');
      return;
    }

    if (newValue == true) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Mở khóa tài khoản'),
            content: Text(
              'Bạn có chắc muốn mở khóa tài khoản thợ "$fullName" không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Mở khóa'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await _unlockMechanic(mechanicId);
      }

      return;
    }

    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Khóa tài khoản thợ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bạn đang tắt tài khoản của thợ "$fullName".'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Lý do khóa',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = reasonController.text.trim();

                Navigator.pop(
                  context,
                  text.isEmpty ? 'Admin đã khóa tài khoản' : text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Khóa'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason != null && reason.isNotEmpty) {
      await _lockMechanic(mechanicId, reason);
    }
  }

  Future<void> _lockMechanic(int mechanicId, String reason) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updatedMechanic = await _service.lockMechanic(
        mechanicId,
        reason,
      );

      if (!mounted) return;

      _replaceMechanicInList(updatedMechanic);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã khóa tài khoản thợ')),
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _unlockMechanic(int mechanicId) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final updatedMechanic = await _service.unlockMechanic(mechanicId);

      if (!mounted) return;

      _replaceMechanicInList(updatedMechanic);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã mở khóa tài khoản thợ')),
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Widget _buildStatusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? Colors.green : Colors.red,
        ),
      ),
      child: Text(
        active ? 'ON' : 'OFF',
        style: TextStyle(
          color: active ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> mechanic) {
    final avatarUrl = _getText(mechanic, 'avatarUrl');
    final fullName = _getText(mechanic, 'fullName');

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    final firstChar = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'T';

    return CircleAvatar(
      backgroundColor: Colors.blue.shade100,
      child: Text(
        firstChar,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_filteredMechanics.isEmpty) {
      return const Center(
        child: Text('Không có tài khoản thợ nào'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMechanics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredMechanics.length,
        itemBuilder: (context, index) {
          final mechanic = _filteredMechanics[index] as Map<String, dynamic>;
          final active = _isActive(mechanic);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () => _openMechanicDetailScreen(mechanic),
              leading: _buildAvatar(mechanic),
              title: Text(
                _getText(mechanic, 'fullName'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getText(mechanic, 'email')),
                    Text(_getText(mechanic, 'phone')),
                    const SizedBox(height: 6),
                    _buildStatusChip(active),
                  ],
                ),
              ),
              trailing: Switch(
                value: active,
                onChanged: _isUpdatingStatus
                    ? null
                    : (value) {
                  _toggleMechanicStatus(mechanic, value);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Danh sách thợ'),
              actions: [
                IconButton(
                  onPressed: _loadMechanics,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateMechanicScreen,
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm thợ'),
      ),
      body: Column(
        children: [
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Danh sách thợ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadMechanics,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, email hoặc số điện thoại',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
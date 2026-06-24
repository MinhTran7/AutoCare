import 'package:flutter/material.dart';

import '../../services/profile_service.dart';
import '../../storage/token_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.getMe();

      if (!mounted) return;

      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearAuthData();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  String _displayValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Chưa cập nhật';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profile = _profile;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hồ sơ cá nhân'),
        ),
        body: const Center(
          child: Text('Không có dữ liệu người dùng'),
        ),
      );
    }

    final avatarUrl = profile['avatarUrl'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                avatarUrl != null && avatarUrl.toString().isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.toString().isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                _displayValue(profile['fullName']),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: Text(
                _displayValue(profile['role']),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),

            _ProfileItem(
              icon: Icons.email,
              title: 'Email',
              value: _displayValue(profile['email']),
            ),
            _ProfileItem(
              icon: Icons.phone,
              title: 'Số điện thoại',
              value: _displayValue(profile['phone']),
            ),
            _ProfileItem(
              icon: Icons.location_on,
              title: 'Địa chỉ',
              value: _displayValue(profile['address']),
            ),
            _ProfileItem(
              icon: Icons.calendar_today,
              title: 'Ngày tạo tài khoản',
              value: _displayValue(profile['createdAt']),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/edit-profile',
                    arguments: profile,
                  );

                  if (result == true) {
                    _loadProfile();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa thông tin'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/change-password');
                },
                icon: const Icon(Icons.lock),
                label: const Text('Đổi mật khẩu'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
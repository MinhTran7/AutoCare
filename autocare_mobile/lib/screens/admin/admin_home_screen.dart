import 'package:flutter/material.dart';

import '../../storage/token_storage.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearAuthData();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  void _goToAdminProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _goToManageMechanics(BuildContext context) {
    Navigator.pushNamed(context, '/admin-mechanics');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text('Màn hình quản trị'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(
              Icons.admin_panel_settings,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            const Text(
              'Quản trị hệ thống',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Quản lý tài khoản thợ sửa xe',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 32),

            _AdminMenuCard(
              icon: Icons.account_circle,
              title: 'Hồ sơ Admin',
              subtitle: 'Xem thông tin tài khoản quản trị',
              onTap: () => _goToAdminProfile(context),
            ),

            const SizedBox(height: 12),

            _AdminMenuCard(
              icon: Icons.engineering,
              title: 'Quản lý thợ sửa xe',
              subtitle: 'Xem danh sách, thêm thợ, sửa thông tin, bật/tắt tài khoản',
              onTap: () => _goToManageMechanics(context),
            ),

            const SizedBox(height: 12),

            _AdminMenuCard(
              icon: Icons.logout,
              title: 'Đăng xuất',
              subtitle: 'Thoát khỏi tài khoản quản trị',
              iconColor: Colors.red,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}
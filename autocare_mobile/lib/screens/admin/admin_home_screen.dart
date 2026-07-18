import 'package:flutter/material.dart';

import '../../storage/token_storage.dart';
import 'admin_customers_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_garages_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_services_screen.dart';
import 'manage_mechanics_screen.dart';

enum AdminSection {
  dashboard,
  customers,
  mechanics,
  services,
  inventory,
  garages,
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  AdminSection _section = AdminSection.dashboard;

  static const _sidebarBreakpoint = 900.0;

  Future<void> _logout() async {
    await TokenStorage.clearAuthData();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String get _title {
    switch (_section) {
      case AdminSection.dashboard:
        return 'Dashboard';
      case AdminSection.customers:
        return 'Khách hàng';
      case AdminSection.mechanics:
        return 'Thợ sửa xe';
      case AdminSection.services:
        return 'Dịch vụ';
      case AdminSection.inventory:
        return 'Kho phụ tùng';
      case AdminSection.garages:
        return 'Garage / Chi nhánh';
    }
  }

  Widget get _body {
    switch (_section) {
      case AdminSection.dashboard:
        return AdminDashboardScreen(
          onOpenInventory: () => setState(() => _section = AdminSection.inventory),
        );
      case AdminSection.customers:
        return const AdminCustomersScreen();
      case AdminSection.mechanics:
        return const ManageMechanicsScreen(embedded: true);
      case AdminSection.services:
        return const AdminServicesScreen();
      case AdminSection.inventory:
        return const AdminInventoryScreen();
      case AdminSection.garages:
        return const AdminGaragesScreen();
    }
  }

  Widget _buildNavList({VoidCallback? onNavigate}) {
    ListTile tile({
      required AdminSection section,
      required IconData icon,
      required String label,
    }) {
      final selected = _section == section;
      return ListTile(
        selected: selected,
        leading: Icon(icon),
        title: Text(label),
        onTap: () {
          setState(() => _section = section);
          onNavigate?.call();
        },
      );
    }

    return ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Color(0xff1565c0)),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'AutoCare Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        tile(
          section: AdminSection.dashboard,
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
        ),
        tile(
          section: AdminSection.customers,
          icon: Icons.people_outline,
          label: 'Khách hàng',
        ),
        tile(
          section: AdminSection.mechanics,
          icon: Icons.engineering_outlined,
          label: 'Thợ sửa xe',
        ),
        tile(
          section: AdminSection.services,
          icon: Icons.build_outlined,
          label: 'Dịch vụ',
        ),
        tile(
          section: AdminSection.inventory,
          icon: Icons.inventory_2_outlined,
          label: 'Kho phụ tùng',
        ),
        tile(
          section: AdminSection.garages,
          icon: Icons.store_mall_directory_outlined,
          label: 'Garage',
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Hồ sơ Admin'),
          onTap: () {
            onNavigate?.call();
            Navigator.pushNamed(context, '/profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          onTap: _logout,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _sidebarBreakpoint;

        return Scaffold(
          backgroundColor: const Color(0xfff5f7fb),
          appBar: AppBar(
            title: Text(_title),
            actions: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: 'Hồ sơ',
              ),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                tooltip: 'Đăng xuất',
              ),
            ],
          ),
          drawer: wide
              ? null
              : Drawer(
                  child: SafeArea(
                    child: Builder(
                      builder: (drawerContext) => _buildNavList(
                        onNavigate: () => Navigator.pop(drawerContext),
                      ),
                    ),
                  ),
                ),
          body: Row(
            children: [
              if (wide)
                Material(
                  elevation: 1,
                  child: SizedBox(
                    width: 260,
                    child: _buildNavList(),
                  ),
                ),
              Expanded(child: _body),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../storage/token_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearAuthData();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _goToGarage(BuildContext context) {
    Navigator.pushNamed(context, '/garage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoCare Home"),
        actions: [
          IconButton(
            onPressed: () => _goToProfile(context),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Trang Home",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _goToProfile(context),
                  icon: const Icon(Icons.person),
                  label: const Text('Hồ sơ cá nhân'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _goToGarage(context),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Garage xe của tôi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
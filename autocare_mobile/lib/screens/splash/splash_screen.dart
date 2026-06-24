import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStartScreen();
  }

  Future<void> _checkStartScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await TokenStorage.getToken();
    final rememberMe = await TokenStorage.getRememberMe();
    final role = await TokenStorage.getRole();

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    final hasToken = token != null && token.isNotEmpty;
    final normalizedRole = role?.toUpperCase();

    if (hasToken && rememberMe) {
      if (normalizedRole == 'ADMIN') {
        Navigator.pushReplacementNamed(context, '/admin-home');
        return;
      }

      if (normalizedRole == 'MECHANIC') {
        Navigator.pushReplacementNamed(context, '/mechanic-home');
        return;
      }

      if (normalizedRole == 'CUSTOMER') {
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      await TokenStorage.clearAuthData();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (hasToken && !rememberMe) {
      await TokenStorage.clearAuthData();
    }

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffF5F7FA),
      body: Center(
        child: Text(
          'AutoCare',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
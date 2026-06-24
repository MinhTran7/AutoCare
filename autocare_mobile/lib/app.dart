import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/change_password_screen.dart';

import 'screens/garage/garage_screen.dart';
import 'screens/garage/add_vehicle_screen.dart';
import 'screens/garage/vehicle_detail_screen.dart';
import 'screens/garage/edit_vehicle_screen.dart';

import 'screens/mechanic/mechanic_home_screen.dart';

import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/create_mechanic_screen.dart';
import 'screens/admin/manage_mechanics_screen.dart';
import 'screens/admin/mechanic_detail_screen.dart';
import 'screens/admin/edit_mechanic_screen.dart';
import 'screens/auth/verify_email_screen.dart';

class AutoCareApp extends StatelessWidget {
  const AutoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoCare',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),

        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        '/home': (context) => const HomeScreen(),

        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),

        '/garage': (context) => const GarageScreen(),
        '/add-vehicle': (context) => const AddVehicleScreen(),
        '/vehicle-detail': (context) => const VehicleDetailScreen(),
        '/edit-vehicle': (context) => const EditVehicleScreen(),

        '/mechanic-home': (context) => const MechanicHomeScreen(),

        '/admin-home': (context) => const AdminHomeScreen(),
        '/admin-mechanics': (context) => const ManageMechanicsScreen(),
        '/create-mechanic': (context) => const CreateMechanicScreen(),
        '/mechanic-detail': (context) => const MechanicDetailScreen(),
        '/edit-mechanic': (context) => const EditMechanicScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}
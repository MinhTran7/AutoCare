import 'package:flutter/material.dart';

import '../../storage/token_storage.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController _emailOrPhoneController =
  TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  String _getRouteByRole(String? role) {
    final normalizedRole = role?.toUpperCase();

    if (normalizedRole == 'ADMIN') {
      return '/admin-home';
    }

    if (normalizedRole == 'MECHANIC') {
      return '/mechanic-home';
    }

    return '/home';
  }

  bool _isGmail(String value) {
    final gmailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(value.trim().toLowerCase());
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email hoặc số điện thoại';
    }

    final input = value.trim().toLowerCase();

    final gmailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$');
    final phoneRegex = RegExp(r'^[0-9]{10}$');

    final isValidGmail = gmailRegex.hasMatch(input);
    final isValidPhone = phoneRegex.hasMatch(input);

    if (!isValidGmail && !isValidPhone) {
      return 'Email phải là Gmail hoặc số điện thoại phải gồm đúng 10 số';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.trim().length < 6) {
      return 'Mật khẩu phải có tối thiểu 6 ký tự';
    }

    return null;
  }

  Future<void> _showVerifyEmailDialog(String email) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tài khoản chưa xác thực'),
          content: Text(
            'Tài khoản $email chưa được xác thực email. Bạn có muốn chuyển sang màn nhập mã xác thực không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Để sau'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamed(
                  context,
                  '/verify-email',
                  arguments: {
                    'email': email,
                  },
                );
              },
              child: const Text('Xác thực ngay'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final emailOrPhone = _emailOrPhoneController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] != true) {
        final message = result['message'] ?? 'Đăng nhập thất bại';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );

        final lowerMessage = message.toString().toLowerCase();

        if (lowerMessage.contains('xác thực email') &&
            _isGmail(emailOrPhone)) {
          await _showVerifyEmailDialog(emailOrPhone);
        }

        return;
      }

      final token = result['token'];
      final user = result['user'];

      final role = user?['role']?.toString();
      final status = user?['status']?.toString().toUpperCase();

      if (status == 'LOCKED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản của bạn đã bị khóa'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (status == 'PENDING_VERIFY') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản chưa được xác thực email'),
            backgroundColor: Colors.red,
          ),
        );

        if (_isGmail(emailOrPhone)) {
          await _showVerifyEmailDialog(emailOrPhone);
        }

        return;
      }

      if (token == null || token.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không nhận được token đăng nhập'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await TokenStorage.saveToken(token.toString());
      await TokenStorage.saveRememberMe(_rememberMe);

      if (role != null && role.isNotEmpty) {
        await TokenStorage.saveRole(role);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công'),
        ),
      );

      final route = _getRouteByRole(role);

      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.car_repair,
                  size: 90,
                  color: Color(0xff1565C0),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AutoCare',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để tiếp tục',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailOrPhoneController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc số điện thoại',
                    hintText: 'example@gmail.com hoặc 0901234567',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmailOrPhone,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/admin_mechanic_service.dart';

class CreateMechanicScreen extends StatefulWidget {
  const CreateMechanicScreen({super.key});

  @override
  State<CreateMechanicScreen> createState() => _CreateMechanicScreenState();
}

class _CreateMechanicScreenState extends State<CreateMechanicScreen> {
  final AdminMechanicService _service = AdminMechanicService();
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _createMechanic() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _service.createMechanic(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thợ thành công'),
        ),
      );

      Navigator.pop(context, true);
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

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Email không được để trống';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(text)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Số điện thoại không được để trống';
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
      return 'Số điện thoại phải gồm đúng 10 chữ số';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (text.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text('Tạo tài khoản thợ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.engineering,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Thông tin tài khoản thợ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _fullNameController,
                  decoration: _inputDecoration('Họ tên thợ', Icons.person),
                  validator: (value) {
                    return _requiredValidator(
                      value,
                      'Họ tên không được để trống',
                    );
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email', Icons.email),
                  validator: _emailValidator,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Số điện thoại', Icons.phone),
                  validator: _phoneValidator,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('Mật khẩu', Icons.lock).copyWith(
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
                  validator: _passwordValidator,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  decoration: _inputDecoration(
                    'Địa chỉ',
                    Icons.location_on,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createMechanic,
                    icon: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.person_add),
                    label: Text(
                      _isLoading ? 'Đang tạo...' : 'Tạo tài khoản',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
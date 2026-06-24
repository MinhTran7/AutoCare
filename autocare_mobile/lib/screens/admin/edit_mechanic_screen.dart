import 'package:flutter/material.dart';

import '../../services/admin_mechanic_service.dart';

class EditMechanicScreen extends StatefulWidget {
  const EditMechanicScreen({super.key});

  @override
  State<EditMechanicScreen> createState() => _EditMechanicScreenState();
}

class _EditMechanicScreenState extends State<EditMechanicScreen> {
  final AdminMechanicService _service = AdminMechanicService();
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _isSaving = false;
  bool _hasInitData = false;

  Map<String, dynamic>? _mechanic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasInitData) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _mechanic = args;

      _fullNameController.text = _getText(args, 'fullName');
      _phoneController.text = _getText(args, 'phone');
      _addressController.text = _getText(args, 'address');
      _avatarUrlController.text = _getText(args, 'avatarUrl');
    }

    _hasInitData = true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  String _getText(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value == null) return '';

    return value.toString();
  }

  int _getMechanicId() {
    final mechanic = _mechanic;

    if (mechanic == null) return 0;

    final value = mechanic['id'];

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final mechanicId = _getMechanicId();

    if (mechanicId == 0) {
      _showError('Không xác định được ID thợ');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedMechanic = await _service.updateMechanic(
        mechanicId: mechanicId,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thợ thành công'),
        ),
      );

      Navigator.pop(context, updatedMechanic);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_mechanic == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sửa thông tin thợ'),
        ),
        body: const Center(
          child: Text('Không có dữ liệu thợ'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text('Sửa thông tin thợ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.edit,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Cập nhật thông tin thợ',
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
                  enabled: false,
                  initialValue: _getText(_mechanic!, 'email'),
                  decoration: _inputDecoration('Email', Icons.email).copyWith(
                    fillColor: Colors.grey.shade100,
                  ),
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
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  decoration: _inputDecoration(
                    'Địa chỉ',
                    Icons.location_on,
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _avatarUrlController,
                  keyboardType: TextInputType.url,
                  decoration: _inputDecoration(
                    'Avatar URL',
                    Icons.image,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
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
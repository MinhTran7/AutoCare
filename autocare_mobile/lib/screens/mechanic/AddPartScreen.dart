import 'package:flutter/material.dart';
import '../../services/mechanic_api_service.dart';

class AddPartScreen extends StatefulWidget {

  final int bookingId;

  const AddPartScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<AddPartScreen> createState() =>
      _AddPartScreenState();

}

class _AddPartScreenState extends State<AddPartScreen> {
  final MechanicApiService _apiService = MechanicApiService();

  final _formKey = GlobalKey<FormState>();
  final _sparePartIdController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _sparePartIdController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String? _positiveIntValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label không được để trống';
    }

    final parsed = int.tryParse(value.trim());

    if (parsed == null) {
      return '$label phải là số nguyên';
    }

    if (parsed <= 0) {
      return '$label phải lớn hơn 0';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.addSparePart(
        widget.bookingId,
        int.parse(_sparePartIdController.text.trim()),
        int.parse(_quantityController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm phụ tùng')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm phụ tùng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn sửa chữa #${widget.bookingId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _sparePartIdController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Mã phụ tùng'),
                validator: (value) =>
                    _positiveIntValidator(value, 'Mã phụ tùng'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Số lượng'),
                validator: (value) =>
                    _positiveIntValidator(value, 'Số lượng'),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Thêm phụ tùng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
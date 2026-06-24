import 'package:flutter/material.dart';

import '../../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final VehicleService _vehicleService = VehicleService();

  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;

  Future<void> _createVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _vehicleService.createVehicle(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        licensePlate: _licensePlateController.text.trim(),
        manufacturingYear: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim(),
        mileage: int.parse(_mileageController.text.trim()),
        isDefault: _isDefault,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm xe thành công')),
      );

      Navigator.pop(context, true);
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

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _yearValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Năm sản xuất không được để trống';
    }

    final year = int.tryParse(value.trim());

    if (year == null) {
      return 'Năm sản xuất phải là số';
    }

    if (year < 1900 || year > DateTime.now().year + 1) {
      return 'Năm sản xuất không hợp lệ';
    }

    return null;
  }

  String? _mileageValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số km không được để trống';
    }

    final mileage = int.tryParse(value.trim());

    if (mileage == null) {
      return 'Số km phải là số';
    }

    if (mileage < 0) {
      return 'Số km không hợp lệ';
    }

    return null;
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
        title: const Text('Thêm xe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: _inputDecoration('Hãng xe'),
                validator: (value) =>
                    _requiredValidator(value, 'Hãng xe không được để trống'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: _inputDecoration('Dòng xe'),
                validator: (value) =>
                    _requiredValidator(value, 'Dòng xe không được để trống'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _licensePlateController,
                decoration: _inputDecoration('Biển số xe'),
                validator: (value) =>
                    _requiredValidator(value, 'Biển số xe không được để trống'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Năm sản xuất'),
                validator: _yearValidator,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _colorController,
                decoration: _inputDecoration('Màu xe'),
                validator: (value) =>
                    _requiredValidator(value, 'Màu xe không được để trống'),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Số km đã đi'),
                validator: _mileageValidator,
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                title: const Text('Đặt làm xe mặc định'),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createVehicle,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm xe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
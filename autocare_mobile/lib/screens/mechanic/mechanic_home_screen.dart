import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../storage/token_storage.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  static const String baseUrl = 'http://localhost:8080/api/users/me';

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Bạn chưa đăng nhập hoặc token đã hết hạn');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        setState(() {
          _user = data;
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Không tải được thông tin tài khoản');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearAuthData();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  String _getText(String key) {
    final user = _user;

    if (user == null) return '';

    final value = user[key];

    if (value == null) return '';

    return value.toString();
  }

  String _getFullName() {
    final fullName = _getText('fullName');

    if (fullName.isNotEmpty) return fullName;

    return _getText('full_name');
  }

  String _getAvatarUrl() {
    final avatarUrl = _getText('avatarUrl');

    if (avatarUrl.isNotEmpty) return avatarUrl;

    return _getText('avatar_url');
  }

  Widget _buildAvatar() {
    final avatarUrl = _getAvatarUrl();
    final fullName = _getFullName();

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 46,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    final firstChar = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'T';

    return CircleAvatar(
      radius: 46,
      backgroundColor: Colors.blue.shade100,
      child: Text(
        firstChar,
        style: const TextStyle(
          fontSize: 34,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? 'Chưa có' : value;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final fullName = _getFullName();

    return RefreshIndicator(
      onRefresh: _loadMyProfile,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),

          Center(child: _buildAvatar()),

          const SizedBox(height: 14),

          Center(
            child: Text(
              fullName.isEmpty ? 'Tài khoản thợ' : fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'Bạn chỉ có quyền xem thông tin và đăng xuất',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 24),

          _infoRow('Họ tên', fullName),
          _infoRow('Email', _getText('email')),
          _infoRow('Số điện thoại', _getText('phone')),
          _infoRow('Địa chỉ', _getText('address')),
          _infoRow('Vai trò', _getText('role')),
          _infoRow('Trạng thái', _getText('status')),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text('Màn hình thợ sửa'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadMyProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
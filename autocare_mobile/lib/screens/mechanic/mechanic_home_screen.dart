import 'package:flutter/material.dart';
import '../../services/mechanic_api_service.dart';
import '../../storage/token_storage.dart'; // Đảm bảo import đúng đường dẫn lưu trữ token

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  _MechanicHomeScreenState createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  final MechanicApiService _apiService = MechanicApiService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String _currentStatus = 'AVAILABLE';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _apiService.fetchAssignedBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách: $e')),
        );
      }
    }
  }

  Future<void> _updateMechanicStatus(String newStatus) async {
    try {
      await _apiService.updateStatus(newStatus);
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái thành: $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật trạng thái: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Thợ máy'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Đổi trạng thái',
            onSelected: _updateMechanicStatus,
            icon: const Icon(Icons.account_circle),
            itemBuilder: (BuildContext context) {
              return {'AVAILABLE', 'BUSY'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
      ),
      // Thêm Drawer tại đây
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Tùy chọn Thợ máy', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Thông tin cá nhân'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile'); // Điều hướng tới trang Profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Theo dõi chấm công'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/attendance'); // Đảm bảo đã khai báo route này
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/change-password'); // Điều hướng tới trang Đổi mật khẩu
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () async {
                await TokenStorage.clearAuthData(); // Xóa token cũ[cite: 3]
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trạng thái hoạt động:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_currentStatus, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                ? const Center(child: Text('Bạn chưa có công việc nào được giao.'))
                : ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text('Dịch vụ: ${booking['serviceName'] ?? 'N/A'}'),
                    subtitle: Text('Trạng thái: ${booking['status']}'),
                    trailing: ElevatedButton(
                      onPressed: () { /* Chuyển trang chi tiết */ },
                      child: const Text('Chi tiết'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/mechanic_api_service.dart';

class MechanicHomeScreen extends StatefulWidget {

  const MechanicHomeScreen({super.key});

  @override
  _MechanicHomeScreenState createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  final MechanicApiService _apiService = MechanicApiService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _apiService.fetchAssignedBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Hiển thị lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bảng điều khiển Thợ máy'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBookings,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Dịch vụ: ${booking['serviceName'] ?? 'N/A'}'),
              subtitle: Text('Trạng thái: ${booking['status']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Chuyển sang trang chi tiết hoặc cập nhật trạng thái
                },
                child: Text('Chi tiết'),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/mechanic_api_service.dart';
import '../../storage/token_storage.dart';
import 'AddPartScreen.dart'; // Đảm bảo import đúng đường dẫn lưu trữ token

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
    setState(() => _isLoading = true);
    try {
      final bookings = await _apiService.getDashboardBookings();
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Thợ máy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: "Check In",
            onPressed: () async {
              try {
                await _apiService.checkIn();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Check In thành công"),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst("Exception: ", "")),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Check Out",
            onPressed: () async {
              try {
                await _apiService.checkOut();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Check Out thành công"),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst("Exception: ", "")),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          booking["licensePlate"] ?? "Không có biển số",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text("Garage: ${booking["garageName"]}"),

                        Text(
                          "Ngày: ${booking["bookingDate"]}",
                        ),

                        Text(
                          "Giờ: ${booking["startTime"]}",
                        ),

                        Text(
                          "Trạng thái: ${booking["status"]}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            if (booking["status"] == "PENDING") ...[
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await _apiService.acceptBooking(
                                      booking["id"],
                                    );

                                    _loadBookings();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Đã nhận đơn"),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Nhận"),
                              ),

                              const SizedBox(width: 8),

                              OutlinedButton(
                                onPressed: () async {
                                  try {
                                    await _apiService.rejectBooking(
                                      booking["id"],
                                    );

                                    _loadBookings();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Đã từ chối"),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Từ chối"),
                              ),
                            ],

                            if (booking["status"] == "CONFIRMED")
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await _apiService.startRepair(
                                      booking["id"],
                                    );

                                    _loadBookings();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Đã bắt đầu sửa"),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Bắt đầu"),
                              ),

                            if (booking["status"] == "IN_PROGRESS")
                              Row(
                                children: [

                                  ElevatedButton(

                                    onPressed: () async {

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddPartScreen(
                                            bookingId: booking["id"],
                                          ),
                                        ),
                                      );

                                    },

                                    child: const Text("Thêm phụ tùng"),
                                  ),

                                  const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await _apiService.completeBooking(
                                      booking["id"],
                                    );

                                    _loadBookings();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Đã hoàn thành"),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Hoàn thành"),
                              ),
                                ],
                              ),
                          ],
                        ),
                      ],
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
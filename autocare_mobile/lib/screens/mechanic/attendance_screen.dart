import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập, bạn nên thay thế bằng API thực tế
    final List<Map<String, String>> attendanceLogs = [
      {'date': '18/07/2026', 'time': '08:00', 'status': 'Vào ca'},
      {'date': '18/07/2026', 'time': '17:00', 'status': 'Tan ca'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử chấm công')),
      body: ListView.builder(
        itemCount: attendanceLogs.length,
        itemBuilder: (context, index) {
          final log = attendanceLogs[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(log['date']!),
              subtitle: Text('${log['status']} - ${log['time']}'),
            ),
          );
        },
      ),
    );
  }
}
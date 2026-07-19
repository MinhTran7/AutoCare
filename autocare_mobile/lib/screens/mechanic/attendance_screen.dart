import 'package:flutter/material.dart';

import '../../services/mechanic_api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  final MechanicApiService api = MechanicApiService();

  List<dynamic> attendance = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    try{

      final data = await api.getAttendanceHistory();

      setState(() {

        attendance = data;
        loading = false;

      });

    }catch(e){

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Lịch sử chấm công"),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : attendance.isEmpty
          ? const Center(
        child: Text("Chưa có dữ liệu"),
      )
          : ListView.builder(

        itemCount: attendance.length,

        itemBuilder: (context,index){

          final item = attendance[index];

          return Card(

            margin: const EdgeInsets.all(10),

            child: ListTile(

              leading: const CircleAvatar(
                child: Icon(Icons.access_time),
              ),

              title: Text(
                item["workDate"] ?? "",
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    "Check In : ${item["checkInTime"] ?? "--"}",
                  ),

                  Text(
                    "Check Out : ${item["checkOutTime"] ?? "--"}",
                  ),

                ],
              ),

            ),

          );

        },

      ),

    );
  }
}
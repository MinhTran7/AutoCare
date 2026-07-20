import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class MechanicApiService {

  Future<Map<String,String>> _headers() async {

    final token = await TokenStorage.getToken();

    return {
      "Authorization":"Bearer $token",
      "Content-Type":"application/json"
    };
  }

  //----------------------------
  // Đơn đang chờ
  //----------------------------

  Future<List<dynamic>> getWaitingBookings() async{

    final response=await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/waiting"),
      headers:await _headers(),
    );

    if(response.statusCode==200){
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  //----------------------------
  // Đơn đã nhận
  //----------------------------

  Future<List<dynamic>> getConfirmedBookings() async{

    final response=await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/confirmed"),
      headers:await _headers(),
    );

    if(response.statusCode==200){
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  //----------------------------
  // Đơn đang sửa
  //----------------------------

  Future<List<dynamic>> getRepairingBookings() async{

    final response=await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/repairing"),
      headers:await _headers(),
    );

    if(response.statusCode==200){
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  Future<List<dynamic>> getDashboardBookings() async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/dashboard"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  Future<void> addSparePart(
      int bookingId,
      int sparePartId,
      int quantity,
      ) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/$bookingId/parts"),
      headers: await _headers(),
      body: jsonEncode({
        "sparePartId": sparePartId,
        "quantity": quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  //----------------------------
  // Lịch sử
  //----------------------------

  Future<List<dynamic>> getMyBookings() async{

    final response=await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/my"),
      headers:await _headers(),
    );

    if(response.statusCode==200){
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  //----------------------------
  // Nhận đơn
  //----------------------------

  Future<void> acceptBooking(int id) async{

    final response=await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/$id/accept"),
      headers:await _headers(),
    );

    if(response.statusCode!=200){
      throw Exception(response.body);
    }

  }

  //----------------------------
  // Từ chối
  //----------------------------

  Future<void> rejectBooking(int id) async{

    final response=await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/$id/reject"),
      headers:await _headers(),
    );

    if(response.statusCode!=200){
      throw Exception(response.body);
    }

  }

  //----------------------------
  // Bắt đầu sửa
  //----------------------------

  Future<void> startRepair(int id) async{

    final response=await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/$id/start"),
      headers:await _headers(),
    );

    if(response.statusCode!=200){
      throw Exception(response.body);
    }

  }

  //----------------------------
  // Hoàn thành
  //----------------------------

  Future<void> completeBooking(int id) async{

    final response=await http.put(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/bookings/$id/complete"),
      headers:await _headers(),
    );

    if(response.statusCode!=200){
      throw Exception(response.body);
    }

  }

  //----------------------------
  // Check in
  //----------------------------

  Future<void> checkIn() async{

    final response=await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/check-in"),
      headers:await _headers(),
    );

    if(response.statusCode!=200){
      throw Exception(response.body);
    }

  }

  //----------------------------
  // Check out
  //----------------------------

  Future<void> checkOut() async{

    final response=await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/mechanics/check-out"),
      headers:await _headers(),
    );

    if(response.statusCode!=200){
      throw Exception(response.body);
    }

  }

  Future<List<dynamic>> getAttendanceHistory() async {

    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/mechanics/attendance",
      ),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

}
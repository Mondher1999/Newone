import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentApiService {
  //final String baseUrl = 'http://10.0.2.2:3000/appointment/appointments';
  final String baseUrl =
      'https://madidou-backend.onrender.com/appointment/appointments';

  Future<http.Response> createAppointment(
      String userId, Map<String, dynamic> appointmentData) async {
    var uri = Uri.parse('$baseUrl/$userId');
    var response = await http.post(uri,
        body: json.encode(appointmentData),
        headers: {'Content-Type': 'application/json'});
    return response;
  }

  Future<http.Response> checkCreateUpdateAppointment(String userId, String id,
      DateTime dateAppointment, String ownerId, String status) async {
    var uri = Uri.parse('$baseUrl/checkCreateUpdate');
    var body = json.encode({
      "userId": userId,
      "id": id,
      "dateAppointment": dateAppointment.toIso8601String(),
      "ownerId": ownerId,
      "status": status
    });
    var response = await http
        .post(uri, body: body, headers: {'Content-Type': 'application/json'});
    return response;
  }

  Future<http.Response> updateAppointment(
      String id, Map<String, dynamic> updateData) async {
    var uri = Uri.parse('$baseUrl/$id');
    var response = await http.patch(uri,
        body: json.encode(updateData),
        headers: {'Content-Type': 'application/json'});
    return response;
  }

  Future<http.Response> getAppointmentsbyproprietaire(String ownerId) async {
    var uri = Uri.parse(
        'https://madidou-backend.onrender.com/appointment/appointmentsOwnerId/$ownerId');
    var response = await http.get(uri);
    return response;
  }

  Future<http.Response> getAppointmentByPropertyAndDate(
      String propertyId, DateTime date) async {
    var uri = Uri.parse(
        '$baseUrl/byPropertyAndDate/$propertyId/${date.toIso8601String()}');
    var response = await http.get(uri);
    return response;
  }

  Future<http.Response> getAppointmentsbylocataire(String userId) async {
    var uri = Uri.parse(
        'https://madidou-backend.onrender.com/appointment/appointmentsUserId/$userId');
    var response = await http.get(uri);
    return response;
  }

  Future<http.Response> acceptAppointment(String id) async {
    var uri = Uri.parse('$baseUrl/$id/accept');
    var response = await http.patch(uri);
    return response;
  }

  Future<http.Response> cancelAppointment(String id) async {
    var uri = Uri.parse('$baseUrl/$id/cancel');
    var response = await http.patch(uri);
    return response;
  }

  Future<http.Response> refuseAppointment(String id) async {
    var uri = Uri.parse('$baseUrl/$id/refuse');
    var response = await http.patch(uri);
    return response;
  }
}

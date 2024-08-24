import 'dart:convert';
import 'package:madidou/data/model/appointment.dart';
import 'package:madidou/services/appointment/appointmentapiservice.dart';

class AppointmentRepository {
  final AppointmentApiService apiService;

  AppointmentRepository({required this.apiService});

  Future<dynamic> createAppointment(
      String userId, Map<String, dynamic> appointmentData) async {
    final response =
        await apiService.createAppointment(userId, appointmentData);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create appointment');
    }
  }

  Future<dynamic> updateAppointment(
      String id, Map<String, dynamic> updateData) async {
    final response = await apiService.updateAppointment(id, updateData);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update appointment');
    }
  }

  Future<List<Appointment>> getAppointmentsbyproprietaire(
      String ownerId) async {
    final response = await apiService.getAppointmentsbyproprietaire(
        ownerId); // Modify the API service to accept a date
    if (response.statusCode == 200) {
      return List<Appointment>.from(
          json.decode(response.body).map((x) => Appointment.fromJson(x)));
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<List<Appointment>> getAppointmentsbylocataire(String userId) async {
    final response = await apiService.getAppointmentsbylocataire(
        userId); // Modify the API service to accept a date
    if (response.statusCode == 200) {
      return List<Appointment>.from(
          json.decode(response.body).map((x) => Appointment.fromJson(x)));
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<bool> acceptAppointment(String id) async {
    final response = await apiService.acceptAppointment(id);
    return response.statusCode == 200;
  }

  Future<bool> refuseAppointment(String id) async {
    final response = await apiService.refuseAppointment(id);
    return response.statusCode == 200;
  }

  Future<dynamic> checkCreateUpdateAppointment(String userId, String id,
      DateTime dateAppointment, String ownerId, String status) async {
    final response = await apiService.checkCreateUpdateAppointment(
        userId, id, dateAppointment, ownerId, status);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json
          .decode(response.body); // Depending on your API, adjust the parsing
    } else {
      throw Exception('Failed to process appointment');
    }
  }

  Future<bool> cancelAppointment(String id) async {
    final response = await apiService.cancelAppointment(id);
    return response.statusCode == 200;
  }
}

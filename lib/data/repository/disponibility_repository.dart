import 'dart:convert';
import 'package:madidou/services/disponibility/disponibilityapiservice.dart';

class DisponibilityRepository {
  final DisponibilityApiService apiService;

  DisponibilityRepository({required this.apiService});

  Future<dynamic> createDisponibility(String userId) async {
    final response = await apiService.createDisponibility(userId);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create disponibility');
    }
  }

  Future<bool> checkUserStatus(String userId) async {
    final response = await apiService.checkUserStatus(userId);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data[
          'activeStatus']; // Assuming 'activeStatus' is the key that holds the boolean result
    } else {
      throw Exception('Failed to check user status');
    }
  }

  Future<dynamic> updateDisponibility(
      String ownerId, List<String> newDates) async {
    final response = await apiService.updateDisponibility(ownerId, newDates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update disponibility');
    }
  }

  Future<List<dynamic>> getDisponibilities(String ownerId) async {
    final response = await apiService.getDisponibilities(ownerId);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load disponibilities');
    }
  }

  // Add blockDisponibility method
  Future<dynamic> blockDisponibility(String propertyId, DateTime date) async {
    final response = await apiService.blockDisponibility(propertyId, date);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to block disponibility');
    }
  }

  // Add unblockDisponibility method
  Future<dynamic> unblockDisponibility(String propertyId, DateTime date) async {
    final response = await apiService.unblockDisponibility(propertyId, date);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to unblock disponibility');
    }
  }
}

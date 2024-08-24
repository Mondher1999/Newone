import 'dart:convert';
import 'package:madidou/data/model/housingFile.dart';
import 'package:madidou/services/HousingFile/housingFile_api_service.dart';

class HousingFileRepository {
  final HousingFileApiService apiService;

  HousingFileRepository({required this.apiService});

  Future<HousingFile> getHousingFileByUserId(String userId) async {
    final response = await apiService.getHousingFileByUserId(userId);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return HousingFile.fromJson(responseData);
    } else {
      throw Exception('Failed to load housing file');
    }
  }

  Future<String> getFileByUserId(String userId, String fieldName) async {
    final response = await apiService.getFileByUserId(userId, fieldName);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData[
          'fileUrl']; // Assuming the response contains a 'fileUrl' field
    } else {
      throw Exception(
          'Failed to load $fieldName for user $userId: ${response.body}');
    }
  }

  Future<bool> createHousingFile(String userId) async {
    try {
      var response = await apiService.createHousingFile(userId);
      if (response.statusCode == 200) {
        return true; // Housing file created successfully
      } else {
        throw Exception('Failed to create housing file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create housing file: $e');
    }
  }

  Future<HousingFile> updateHousingFile(
      String userId, Map<String, dynamic> updateData) async {
    final response = await apiService.updateHousingFile(userId, updateData);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return HousingFile.fromJson(responseData);
    } else {
      throw Exception('Failed to update housing file: ${response.body}');
    }
  }
}

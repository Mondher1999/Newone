import 'dart:convert';
import 'dart:io';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/property/property_api_service.dart';

class PropertyRepository {
  final ApiPropertyService apiService;

  PropertyRepository({required this.apiService});

  Future<List<Property>> getProperties() async {
    final response = await apiService.getProperties();
    if (response.statusCode == 200) {
      final List<dynamic> propertyJson = json.decode(response.body);
      final properties =
          propertyJson.map((json) => Property.fromJson(json)).toList();
      print("Properties fetched: ${properties.length}"); // Debug print
      return properties;
    } else {
      throw Exception('Failed to load Properties');
    }
  }

  Future<List<Property>> getPropertiesByUserId(String id) async {
    final response = await apiService.getPropertiesByUserId(id);
    if (response.statusCode == 200) {
      final List<dynamic> propertyJson = json.decode(response.body);
      final properties =
          propertyJson.map((json) => Property.fromJson(json)).toList();
      print("Properties fetched: ${properties.length}"); // Debug print
      return properties;
    } else {
      throw Exception('Failed to load Properties');
    }
  }

  Future<Property> createProperty(
      Property property, List<File> images, String userId) async {
    final propertyData = property.toJson();
    final response =
        await apiService.createPropertyWithImages(propertyData, images, userId);
    if (response.statusCode == 200) {
      return Property.fromJson(json.decode(response.body));
    } else {
      // Log or handle non-200 responses appropriately
      throw Exception(
          'Failed to create property, Status code: ${response.statusCode}');
    }
  }

  Future<bool> updatePropertyImage(String propertyId, File imageFile) async {
    try {
      var response =
          await apiService.updatePropertyImage(propertyId, imageFile);
      if (response.statusCode == 200) {
        return true; // Image updated successfully
      } else {
        throw Exception('Failed to update image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update image: $e');
    }
  }

  Future<Property> getPropertyById(String id) async {
    final response = await apiService.getPropertyById(id);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Property.fromJson(responseData);
    } else {
      throw Exception('Failed to load Property');
    }
  }

  Future<Property> updateProperty(String id, Property property) async {
    Map<String, dynamic> updatedPropertyData = property.toJson();
    // Make sure the updateProperty call includes all required arguments
    final response = await apiService.updateProperty(id, updatedPropertyData);

    if (response.statusCode == 200) {
      return Property.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update Property');
    }
  }

  Future<bool> deleteProperty(String id) async {
    try {
      final response = await apiService.deleteProperty(id);
      if (response.statusCode == 200) {
        return true; // Image updated successfully
      } else {
        throw Exception('Failed to update image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update image: $e');
    }
  }
}

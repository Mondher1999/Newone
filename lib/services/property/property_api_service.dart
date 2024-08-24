import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiPropertyService {
//  final String baseUrl = 'http://10.0.2.2:3000/property';
  final String baseUrl = 'https://madidou-backend.onrender.com/property';

  Future<http.Response> getPropertiesByUserId(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/properties/user/$userId'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load Properties');
    }
  }

  Future<http.Response> getProperties() async {
    final response = await http.get(Uri.parse('$baseUrl/properties'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load Properties');
    }
  }

  Future<http.Response> getPropertyById(String id) async {
    final url = Uri.parse('$baseUrl/properties/$id');
    final response = await http.get(url);
    return response;
  }

  Future<http.Response> createPropertyWithImages(
      Map<String, dynamic> property, List<File> images, String userId) async {
    var uri = Uri.parse('$baseUrl/properties/$userId');
    var request = http.MultipartRequest('POST', uri);

    property.forEach((key, value) {
      if (value is List) {
        // Serialize array as JSON string
        request.fields[key] = json.encode(value);
      } else {
        request.fields[key] = value.toString();
      }
    });
    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
      ));
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> createProperty(
      Map<String, dynamic> property, String userId) {
    return http.post(
      Uri.parse(
          '$baseUrl/properties/$userId'), // Adjust this if your endpoint is different
      headers: {'Content-Type': 'application/json'},
      body: json.encode(property),
    );
  }

  Future<http.Response> updatePropertyImage(
      String propertyId, File imageFile) async {
    var uri = Uri.parse('$baseUrl/properties/$propertyId/images');
    var request = http.MultipartRequest('PATCH', uri);

    // Add image file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'files', // Ensure this matches the field name expected by your backend
      imageFile.path,
    ));

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateProperty(
      String id, Map<String, dynamic> property) async {
    var uri = Uri.parse('$baseUrl/properties/$id');
    return http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(property),
    );
  }

  Future<http.Response> deleteProperty(String id) {
    return http.delete(Uri.parse('$baseUrl/properties/$id'));
  }
}

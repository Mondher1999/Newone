import 'dart:io';
import 'package:http/http.dart' as http;

class HousingFileApiService {
  // final String baseUrl = 'http://10.0.2.2:3000/housingfile/housingfiles';
  final String baseUrl =
      'https://madidou-backend.onrender.com/housingfile/housingfiles';

  Future<http.Response> getHousingFileByUserId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load housing file');
    }
  }

  Future<http.Response> createHousingFile(String userId) async {
    var uri = Uri.parse('$baseUrl/$userId');
    var request = http.MultipartRequest('POST', uri);

    // Add file to the request

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getFileByUserId(String userId, String fieldName) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId/$fieldName'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load $fieldName for user $userId');
    }
  }

  Future<http.Response> updateHousingFile(
      String userId, Map<String, dynamic> updateData) async {
    var uri = Uri.parse('$baseUrl/$userId');
    var request = http.MultipartRequest('PATCH', uri);

    // Handle files asynchronously
    var multipartFileFutures = <Future<void>>[];

    updateData.forEach((key, value) async {
      if (value is File) {
        var multipartFileFuture = http.MultipartFile.fromPath(key, value.path)
            .then((multipartFile) => request.files.add(multipartFile));
        multipartFileFutures.add(multipartFileFuture);
      } else if (value is String) {
        request.fields[key] = value;
      }
    });

    // Wait for all file conversions to complete
    await Future.wait(multipartFileFutures);

    // Send the request after all files have been added
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}

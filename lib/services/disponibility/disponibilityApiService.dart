import 'dart:convert';
import 'package:http/http.dart' as http;

class DisponibilityApiService {
  // String baseUrl = 'http://10.0.2.2:3000/disponibility/disponibilities';
  //String baseUrl2 = 'http://10.0.2.2:3000/disponibility';
  final String baseUrl =
      'https://madidou-backend.onrender.com/disponibility/disponibilities';

  final String baseUrl2 = 'https://madidou-backend.onrender.com/disponibility';

  Future<http.Response> createDisponibility(String userId) async {
    var uri = Uri.parse('$baseUrl/$userId');
    var body = jsonEncode({});

    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response;
  }

  Future<http.Response> updateDisponibility(
      String ownerId, List<String> newDates) async {
    var uri = Uri.parse('$baseUrl/$ownerId');
    var response = await http.patch(uri,
        body: json.encode({'dates': newDates}),
        headers: {'Content-Type': 'application/json'});
    return response;
  }

  Future<http.Response> checkUserStatus(String userId) async {
    var uri = Uri.parse('$baseUrl2/user/status/$userId');
    var response = await http.get(uri);
    return response;
  }

  Future<http.Response> getDisponibilities(String ownerId) async {
    var uri = Uri.parse('$baseUrl/$ownerId');
    var response = await http.get(uri);
    return response;
  }

  // New method to block a disponibility
  Future<http.Response> blockDisponibility(
      String propertyId, DateTime date) async {
    var uri = Uri.parse('$baseUrl/block/$propertyId');
    var response = await http.post(uri,
        body: json.encode({'dates': date.toIso8601String()}),
        headers: {'Content-Type': 'application/json'});
    return response;
  }

  // New method to unblock a disponibility
  Future<http.Response> unblockDisponibility(
      String propertyId, DateTime date) async {
    var uri = Uri.parse('$baseUrl/unblock/$propertyId');
    var response = await http.post(uri,
        body: json.encode({'dates': date.toIso8601String()}),
        headers: {'Content-Type': 'application/json'});
    return response;
  }
}

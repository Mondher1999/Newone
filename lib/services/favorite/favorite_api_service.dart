import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiFavoriteService {
  //final String baseUrl = 'http://10.0.2.2:3000/favorite';

  final String baseUrl = 'https://madidou-backend.onrender.com/favorite';
  // Add a property to the user's favorites
  Future<http.Response> addFavorite(String propertyId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/$userId'), // Adjust if necessary
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'propertyId': propertyId}),
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to add favorite $userId');
    }
  }

  // Get all favorite properties for the current user
  Future<http.Response> getFavorites(String userId) async {
    final url = Uri.parse('$baseUrl/favorites/user/$userId');
    final response = await http.get(url);
    return response;
  }

  // Remove a property from the user's favorites
  Future<http.Response> removeFavorite(String propertyId, String userId) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/favorites/$userId/${propertyId}'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to remove favorite');
    }
  }
}

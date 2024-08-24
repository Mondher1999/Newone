import 'dart:convert';
import 'package:madidou/data/model/favorite.dart';
import 'package:madidou/data/model/property.dart';
import 'package:madidou/services/favorite/favorite_api_service.dart'; // Assume a model for favorites

class FavoriteRepository {
  final ApiFavoriteService apiService;

  FavoriteRepository({required this.apiService});

  Future<List<Property>> getFavorites(String userId) async {
    final response = await apiService.getFavorites(userId);
    if (response.statusCode == 200) {
      final List<dynamic> favoritesJson = json.decode(response.body);
      return favoritesJson.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  // Function to add a property to user's favorites
  Future<Favorite> addFavorite(String propertyId, String userId) async {
    final response = await apiService.addFavorite(propertyId, userId);
    if (response.statusCode == 200) {
      // Assuming the server returns the created favorite object
      return Favorite.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add favorite');
    }
  }

  // Function to remove a property from user's favorites
  Future<void> removeFavorite(String propertyId, String userId) async {
    final response = await apiService.removeFavorite(propertyId, userId);
    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite');
    }
  }
}

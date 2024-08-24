import 'package:madidou/data/model/property.dart';

abstract class FavoriteState {}

class FavoritesLoading extends FavoriteState {}

class FavoritesLoaded extends FavoriteState {
  final List<Property> properties; // Updated to hold a list of Favorite objects
  FavoritesLoaded(this.properties);
}

class FavoriteAddSuccess extends FavoriteState {
  final String propertyId; // ID of the property added to favorites
  FavoriteAddSuccess(this.propertyId);
}

class FavoriteRemoveSuccess extends FavoriteState {
  final String propertyId; // ID of the property removed from favorites
  FavoriteRemoveSuccess(this.propertyId);
}

class FavoriteError extends FavoriteState {}

// Optional: Define additional states as needed for your application's flow

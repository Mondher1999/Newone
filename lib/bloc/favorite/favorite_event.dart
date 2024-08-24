abstract class FavoriteEvent {}

class FetchFavorites extends FavoriteEvent {
  String userId;
  FetchFavorites(this.userId);
}

class AddFavorite extends FavoriteEvent {
  final String userId;
  final String propertyId;
  AddFavorite(this.propertyId, this.userId);
}

class RemoveFavorite extends FavoriteEvent {
  final String userId;
  final String favoriteId;
  RemoveFavorite(this.favoriteId, this.userId);
}

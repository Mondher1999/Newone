import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madidou/bloc/favorite/favorite_event.dart';
import 'package:madidou/bloc/favorite/favorite_state.dart';
import 'package:madidou/data/repository/favorite_repository.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository favoriteRepository;

  FavoriteBloc({required this.favoriteRepository}) : super(FavoritesLoading()) {
    on<FetchFavorites>((event, emit) async {
      emit(FavoritesLoading());
      try {
        final favorites = await favoriteRepository.getFavorites(event.userId);
        emit(FavoritesLoaded(favorites)); // Use FavoritesLoaded here
      } catch (error) {
        emit(FavoriteError());
      }
    });

    on<AddFavorite>((event, emit) async {
      try {
        final favorite = await favoriteRepository.addFavorite(
            event.propertyId, event.userId);
        emit(FavoriteAddSuccess(
            favorite.propertyId)); // Assuming Favorite has a propertyId field
        // Optionally, refresh the list of favorites
        add(FetchFavorites(event.userId));
      } catch (_) {
        emit(FavoriteError());
      }
    });

    on<RemoveFavorite>((event, emit) async {
      try {
        await favoriteRepository.removeFavorite(event.favoriteId, event.userId);
        emit(FavoriteRemoveSuccess(
            event.favoriteId)); // Pass the favoriteId here
      } catch (_) {
        emit(FavoriteError());
      }
    });
  }
}

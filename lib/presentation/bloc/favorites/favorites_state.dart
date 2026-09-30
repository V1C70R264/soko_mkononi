import 'package:e_commerce/domain/entities/favorite_entity.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteEntity> favorites;
  FavoritesLoaded(this.favorites);

  /// What every heart in the app reads.
  Set<int> get favoriteIds => favorites.map((f) => f.product.id).toSet();
}

/// A toggle failed, but the list we already had is still valid.
/// It extends FavoritesLoaded so `state is FavoritesLoaded` stays true
/// and no heart loses its filled/empty state because of one failed call.
class FavoritesToggleFailed extends FavoritesLoaded {
  final String message;
  FavoritesToggleFailed(super.favorites, this.message);
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
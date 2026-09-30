// lib/presentation/bloc/favorites/favorites_event.dart
abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final int productId;
  ToggleFavoriteEvent(this.productId);
}
// lib/domain/usecases/toggle_favorite.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/repositories/favorites_repository.dart';

class ToggleFavorite {
  final FavoritesRepository repository;
  ToggleFavorite(this.repository);

  Future<Result<bool>> call(int productId) =>
      repository.toggleFavorite(productId);
}
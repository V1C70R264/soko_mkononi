// lib/domain/repositories/favorites_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<Result<List<FavoriteEntity>>> getFavorites();

  /// Returns the new state: true = now favorited, false = now removed.
  Future<Result<bool>> toggleFavorite(int productId);
}
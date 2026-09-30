// lib/domain/usecases/get_favorites.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/favorite_entity.dart';
import 'package:e_commerce/domain/repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository repository;
  GetFavorites(this.repository);

  Future<Result<List<FavoriteEntity>>> call() => repository.getFavorites();
}
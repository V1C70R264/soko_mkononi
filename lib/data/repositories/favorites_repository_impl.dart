// lib/data/repositories/favorites_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:e_commerce/domain/entities/favorite_entity.dart';
import 'package:e_commerce/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;
  FavoritesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<FavoriteEntity>>> getFavorites() async {
    try {
      final favorites = await remoteDataSource.getFavorites();
      return Success(favorites);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load favorites'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<bool>> toggleFavorite(int productId) async {
    try {
      final favorited = await remoteDataSource.toggleFavorite(productId);
      return Success(favorited);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to update favorite'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
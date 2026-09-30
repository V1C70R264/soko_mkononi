// lib/data/datasources/remote/favorites_remote_datasource.dart
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites();
  Future<bool> toggleFavorite(int productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiClient apiClient;
  FavoritesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    final response = await apiClient.dio.get('/favorites/');
    // Not paginated (pagination_class = None), so the body is a plain list.
    final list = response.data as List;
    return list
        .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> toggleFavorite(int productId) async {
    final response = await apiClient.dio.post(
      '/favorites/toggle/',
      data: {'product': productId},
    );
    return response.data['favorited'] as bool;
  }
}
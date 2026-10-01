// lib/data/datasources/remote/promotion_remote_datasource.dart
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getActivePromotions();
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final ApiClient apiClient;
  PromotionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PromotionModel>> getActivePromotions() async {
    final response = await apiClient.dio.get('/promotions/');
    // pagination_class = None on the backend, so this is a plain list.
    final results = response.data as List;
    return results
        .map((json) => PromotionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
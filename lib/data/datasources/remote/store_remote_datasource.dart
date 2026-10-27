// lib/data/datasources/remote/store_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/my_store_model.dart';
import 'package:e_commerce/data/models/product_page_model.dart';
import 'package:e_commerce/data/models/store_page_model.dart';
import 'package:e_commerce/data/models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<StorePageModel> getStores({String query = '', String? cursor});
  Future<ProductPageModel> getStoreProducts(int storeId, {String? cursor});
  Future<MyStoreModel?> getMyStore();
  Future<StoreModel> getStore(int storeId);
  Future<MyStoreModel> applyForStore({
    required String name,
    required String description,
  });
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final ApiClient apiClient;
  StoreRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StorePageModel> getStores({String query = '', String? cursor}) async {
    final response = cursor != null
        ? await apiClient.dio.get(cursor)
        : await apiClient.dio.get(
            '/stores/',
            queryParameters: query.isEmpty ? null : {'search': query},
          );
    return StorePageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductPageModel> getStoreProducts(int storeId, {String? cursor}) async {
    final response = cursor != null
        ? await apiClient.dio.get(cursor)
        : await apiClient.dio.get('/stores/$storeId/products/');
    return ProductPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MyStoreModel?> getMyStore() async {
    try {
      final response = await apiClient.dio.get('/stores/mine/');
      return MyStoreModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // 404 means "has not applied yet". That's a normal state, not a
      // failure, so it becomes null here instead of an error.
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<MyStoreModel> applyForStore({
    required String name,
    required String description,
  }) async {
    final response = await apiClient.dio.post(
      '/stores/apply/',
      data: {'name': name, 'description': description},
    );
    return MyStoreModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<StoreModel> getStore(int storeId) async {
    final response = await apiClient.dio.get('/stores/$storeId/');
    return StoreModel.fromJson(response.data as Map<String, dynamic>);
  }
}
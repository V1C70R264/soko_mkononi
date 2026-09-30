import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/category_model.dart';
import 'package:e_commerce/data/models/product_model.dart';
import 'package:e_commerce/data/models/product_page_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(int categoryId);
  Future<ProductPageModel> searchProducts(String query, {String? cursor});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;
  HomeRemoteDataSourceImpl({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiClient.dio.get('/categories/');
    final results = response.data['results'] as List;
    return results.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final response = await apiClient.dio.get(
      '/products/',
      queryParameters: {'category': categoryId, 'in_stock': true},
    );
    final results = response.data['results'] as List;
    return results.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductPageModel> searchProducts(String query, {String? cursor}) async {
    // A cursor is DRF's full "next" URL (already carries the search term
    // and page number), so we fetch it directly instead of rebuilding
    // query parameters ourselves.
    final response = cursor != null
        ? await apiClient.dio.get(cursor)
        : await apiClient.dio.get(
            '/products/',
            queryParameters: {'search': query},
          );

    return ProductPageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/category_entity.dart';
import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';

abstract class HomeRepository {
  Future<Result<List<CategoryEntity>>> getCategories();
  Future<Result<List<ProductEntity>>> getProductsByCategory(int categoryId);

  /// `cursor` is null for the first page. Pass back a previous result's
  /// `nextCursor` to fetch the following page.
  Future<Result<ProductPageEntity>> searchProducts(String query, {String? cursor});
  Future<Result<ProductPageEntity>> getTrendingProducts({String? cursor});
  Future<Result<ProductPageEntity>> getNewSellerProducts({String? cursor});
}
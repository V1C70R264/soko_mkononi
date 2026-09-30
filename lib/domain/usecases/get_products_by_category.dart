// domain/usecases/get_products_by_category.dart
import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/domain/repositories/home_repository.dart';
import 'package:e_commerce/core/utils/result.dart';

class GetProductsByCategory {
  final HomeRepository repository;
  GetProductsByCategory(this.repository);
  Future<Result<List<ProductEntity>>> call(int categoryId) =>
      repository.getProductsByCategory(categoryId);
}
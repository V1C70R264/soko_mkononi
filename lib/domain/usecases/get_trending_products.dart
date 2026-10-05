// lib/domain/usecases/get_trending_products.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/repositories/home_repository.dart';

class GetTrendingProducts {
  final HomeRepository repository;
  GetTrendingProducts(this.repository);

  Future<Result<ProductPageEntity>> call({String? cursor}) =>
      repository.getTrendingProducts(cursor: cursor);
}
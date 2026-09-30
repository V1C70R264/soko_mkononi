import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/repositories/home_repository.dart';

class SearchProducts {
  final HomeRepository repository;
  SearchProducts(this.repository);

  Future<Result<ProductPageEntity>> call(String query, {String? cursor}) =>
      repository.searchProducts(query, cursor: cursor);
}
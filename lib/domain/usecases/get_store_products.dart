// lib/domain/usecases/get_store_products.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';

class GetStoreProducts {
  final StoreRepository repository;
  GetStoreProducts(this.repository);

  Future<Result<ProductPageEntity>> call(int storeId, {String? cursor}) =>
      repository.getStoreProducts(storeId, cursor: cursor);
}
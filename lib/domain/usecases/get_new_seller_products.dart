// lib/domain/usecases/get_new_seller_products.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/repositories/home_repository.dart';

class GetNewSellerProducts {
  final HomeRepository repository;
  GetNewSellerProducts(this.repository);

  Future<Result<ProductPageEntity>> call({String? cursor}) =>
      repository.getNewSellerProducts(cursor: cursor);
}
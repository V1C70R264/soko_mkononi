// lib/domain/repositories/store_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/my_store_entity.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/entities/store_page_entity.dart';
import 'package:e_commerce/domain/entities/store_entity.dart';

abstract class StoreRepository {
  Future<Result<StorePageEntity>> getStores({String query = '', String? cursor});
  Future<Result<ProductPageEntity>> getStoreProducts(int storeId, {String? cursor});
  Future<Result<StoreEntity>> getStore(int storeId);

  /// A null inside Success means the user has not applied for a store yet.
  Future<Result<MyStoreEntity?>> getMyStore();

  Future<Result<MyStoreEntity>> applyForStore({
    required String name,
    required String description,
  });
}
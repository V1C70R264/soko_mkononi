// lib/domain/usecases/get_store.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/store_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';

class GetStore {
  final StoreRepository repository;
  GetStore(this.repository);

  Future<Result<StoreEntity>> call(int storeId) => repository.getStore(storeId);
}
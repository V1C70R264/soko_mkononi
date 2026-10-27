// lib/domain/usecases/get_my_store.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/my_store_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';

class GetMyStore {
  final StoreRepository repository;
  GetMyStore(this.repository);

  Future<Result<MyStoreEntity?>> call() => repository.getMyStore();
}
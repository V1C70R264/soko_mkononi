// lib/domain/usecases/apply_for_store.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/my_store_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';

class ApplyForStore {
  final StoreRepository repository;
  ApplyForStore(this.repository);

  Future<Result<MyStoreEntity>> call({
    required String name,
    required String description,
  }) {
    return repository.applyForStore(name: name, description: description);
  }
}
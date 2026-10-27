// lib/domain/usecases/get_stores.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/store_page_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';

class GetStores {
  final StoreRepository repository;
  GetStores(this.repository);

  Future<Result<StorePageEntity>> call({String query = '', String? cursor}) =>
      repository.getStores(query: query, cursor: cursor);
}
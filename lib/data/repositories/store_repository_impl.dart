// lib/data/repositories/store_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/store_remote_datasource.dart';
import 'package:e_commerce/domain/entities/my_store_entity.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/entities/store_page_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';
import 'package:e_commerce/domain/entities/store_entity.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  StoreRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<StorePageEntity>> getStores({
    String query = '',
    String? cursor,
  }) async {
    try {
      final page = await remoteDataSource.getStores(query: query, cursor: cursor);
      return Success(page);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load stores'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<ProductPageEntity>> getStoreProducts(
    int storeId, {
    String? cursor,
  }) async {
    try {
      final page =
          await remoteDataSource.getStoreProducts(storeId, cursor: cursor);
      return Success(page);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load store products'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<MyStoreEntity?>> getMyStore() async {
    try {
      final store = await remoteDataSource.getMyStore();
      return Success(store);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load your store'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<MyStoreEntity>> applyForStore({
    required String name,
    required String description,
  }) async {
    try {
      final store = await remoteDataSource.applyForStore(
        name: name,
        description: description,
      );
      return Success(store);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to submit application'));
    } catch (e) {
      return Error(e.toString());
    }
  }

    @override
  Future<Result<StoreEntity>> getStore(int storeId) async {
    try {
      final store = await remoteDataSource.getStore(storeId);
      return Success(store);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load store'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
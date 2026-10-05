// lib/data/repositories/home_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/category_entity.dart';
import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/repositories/home_repository.dart';
import 'package:e_commerce/data/datasources/remote/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Success(categories);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load categories'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getProductsByCategory(int categoryId) async {
    try {
      final products = await remoteDataSource.getProductsByCategory(categoryId);
      return Success(products);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load products'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<ProductPageEntity>> searchProducts(String query, {String? cursor}) async {
    try {
      final page = await remoteDataSource.searchProducts(query, cursor: cursor);
      return Success(page);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to search products'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<ProductPageEntity>> getTrendingProducts({String? cursor}) async {
    try {
      final page = await remoteDataSource.getTrendingProducts(cursor: cursor);
      return Success(page);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load trending products'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<ProductPageEntity>> getNewSellerProducts({String? cursor}) async {
    try {
      final page = await remoteDataSource.getNewSellerProducts(cursor: cursor);
      return Success(page);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load new seller products'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
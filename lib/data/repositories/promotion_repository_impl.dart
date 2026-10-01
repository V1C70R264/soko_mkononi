// lib/data/repositories/promotion_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/promotion_remote_datasource.dart';
import 'package:e_commerce/domain/entities/promotion_entity.dart';
import 'package:e_commerce/domain/repositories/promotion_repository.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;
  PromotionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<PromotionEntity>>> getActivePromotions() async {
    try {
      final promotions = await remoteDataSource.getActivePromotions();
      return Success(promotions);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load promotions'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
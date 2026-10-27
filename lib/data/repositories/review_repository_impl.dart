// lib/data/repositories/review_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/review_remote_datasource.dart';
import 'package:e_commerce/domain/entities/review_entity.dart';
import 'package:e_commerce/domain/entities/can_review_entity.dart';
import 'package:e_commerce/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<ReviewEntity>>> getReviews(int productId) async {
    try {
      final reviews = await remoteDataSource.getReviews(productId);
      return Success(reviews);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load reviews'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<CanReviewEntity>> checkCanReview(int productId) async {
    try {
      final result = await remoteDataSource.checkCanReview(productId);
      return Success(result);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to check review eligibility'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<ReviewEntity>> createReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final review = await remoteDataSource.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      return Success(review);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to submit review'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
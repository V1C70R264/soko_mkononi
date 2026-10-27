// lib/domain/repositories/review_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/review_entity.dart';
import 'package:e_commerce/domain/entities/can_review_entity.dart';

abstract class ReviewRepository {
  Future<Result<List<ReviewEntity>>> getReviews(int productId);
  Future<Result<CanReviewEntity>> checkCanReview(int productId);
  Future<Result<ReviewEntity>> createReview({
    required int productId,
    required int rating,
    required String comment,
  });
}
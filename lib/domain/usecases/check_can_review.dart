// lib/domain/usecases/check_can_review.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/can_review_entity.dart';
import 'package:e_commerce/domain/repositories/review_repository.dart';

class CheckCanReview {
  final ReviewRepository repository;
  CheckCanReview(this.repository);

  Future<Result<CanReviewEntity>> call(int productId) =>
      repository.checkCanReview(productId);
}
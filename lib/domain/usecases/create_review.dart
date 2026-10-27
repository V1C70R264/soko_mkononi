// lib/domain/usecases/create_review.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/review_entity.dart';
import 'package:e_commerce/domain/repositories/review_repository.dart';

class CreateReview {
  final ReviewRepository repository;
  CreateReview(this.repository);

  Future<Result<ReviewEntity>> call({
    required int productId,
    required int rating,
    required String comment,
  }) {
    return repository.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}
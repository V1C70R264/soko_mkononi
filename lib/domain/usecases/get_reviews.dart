// lib/domain/usecases/get_reviews.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/review_entity.dart';
import 'package:e_commerce/domain/repositories/review_repository.dart';

class GetReviews {
  final ReviewRepository repository;
  GetReviews(this.repository);

  Future<Result<List<ReviewEntity>>> call(int productId) =>
      repository.getReviews(productId);
}
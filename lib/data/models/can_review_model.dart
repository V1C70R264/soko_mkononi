// lib/data/models/can_review_model.dart
import 'package:e_commerce/domain/entities/can_review_entity.dart';

class CanReviewModel extends CanReviewEntity {
  const CanReviewModel({
    required super.canReview,
    required super.hasPurchased,
    required super.alreadyReviewed,
  });

  factory CanReviewModel.fromJson(Map<String, dynamic> json) {
    return CanReviewModel(
      canReview: json['can_review'] as bool,
      hasPurchased: json['has_purchased'] as bool,
      alreadyReviewed: json['already_reviewed'] as bool,
    );
  }
}
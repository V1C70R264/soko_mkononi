// lib/domain/entities/can_review_entity.dart
import 'package:equatable/equatable.dart';

class CanReviewEntity extends Equatable {
  final bool canReview;
  final bool hasPurchased;
  final bool alreadyReviewed;

  const CanReviewEntity({
    required this.canReview,
    required this.hasPurchased,
    required this.alreadyReviewed,
  });

  @override
  List<Object?> get props => [canReview, hasPurchased, alreadyReviewed];
}
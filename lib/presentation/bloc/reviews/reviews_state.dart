// lib/presentation/bloc/reviews/reviews_state.dart
import 'package:e_commerce/domain/entities/review_entity.dart';
import 'package:e_commerce/domain/entities/can_review_entity.dart';

abstract class ReviewsState {}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> reviews;
  final CanReviewEntity canReview;
  final bool isSubmitting;

  ReviewsLoaded({
    required this.reviews,
    required this.canReview,
    this.isSubmitting = false,
  });

  ReviewsLoaded copyWith({
    List<ReviewEntity>? reviews,
    CanReviewEntity? canReview,
    bool? isSubmitting,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      canReview: canReview ?? this.canReview,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReviewsError extends ReviewsState {
  final String message;
  ReviewsError(this.message);
}
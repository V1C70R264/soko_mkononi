// lib/presentation/bloc/reviews/reviews_event.dart
abstract class ReviewsEvent {}

class LoadReviews extends ReviewsEvent {
  final int productId;
  LoadReviews(this.productId);
}

class SubmitReview extends ReviewsEvent {
  final int productId;
  final int rating;
  final String comment;
  SubmitReview({required this.productId, required this.rating, required this.comment});
}
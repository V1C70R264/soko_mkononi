// lib/presentation/bloc/reviews/reviews_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_reviews.dart';
import 'package:e_commerce/domain/usecases/check_can_review.dart';
import 'package:e_commerce/domain/usecases/create_review.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final GetReviews getReviews;
  final CheckCanReview checkCanReview;
  final CreateReview createReview;

  ReviewsBloc(this.getReviews, this.checkCanReview, this.createReview)
      : super(ReviewsInitial()) {
    on<LoadReviews>(_onLoad);
    on<SubmitReview>(_onSubmit);
  }

    Future<void> _onLoad(LoadReviews event, Emitter<ReviewsState> emit) async {
    emit(ReviewsLoading());

    final reviewsResult = await getReviews(event.productId);
    final canReviewResult = await checkCanReview(event.productId);

    reviewsResult.fold(
      (reviews) {
        canReviewResult.fold(
          (canReview) => emit(ReviewsLoaded(reviews: reviews, canReview: canReview)),
          (message) => emit(ReviewsError(message)),
        );
      },
      (message) => emit(ReviewsError(message)),
    );
  }

  Future<void> _onSubmit(SubmitReview event, Emitter<ReviewsState> emit) async {
    final current = state;
    if (current is! ReviewsLoaded) return;

    emit(current.copyWith(isSubmitting: true));

    final result = await createReview(
      productId: event.productId,
      rating: event.rating,
      comment: event.comment,
    );

    result.fold(
      (_) => add(LoadReviews(event.productId)), // refresh list + canReview
      (message) => emit(ReviewsError(message)),
    );
  }
}
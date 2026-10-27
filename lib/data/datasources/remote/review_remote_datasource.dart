// lib/data/datasources/remote/review_remote_datasource.dart
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/review_model.dart';
import 'package:e_commerce/data/models/can_review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews(int productId);
  Future<CanReviewModel> checkCanReview(int productId);
  Future<ReviewModel> createReview({
    required int productId,
    required int rating,
    required String comment,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;
  ReviewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReviewModel>> getReviews(int productId) async {
    final response = await apiClient.dio.get(
      '/reviews/',
      queryParameters: {'product': productId},
    );
    // Handles either a plain list or a paginated {"results": [...]}
    // object, depending on the project's global pagination default —
    // ReviewViewSet doesn't set an explicit pagination_class.
    final data = response.data;
    final List rawList = data is List ? data : data['results'] as List;
    return rawList
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CanReviewModel> checkCanReview(int productId) async {
    final response = await apiClient.dio.get(
      '/reviews/can-review/',
      queryParameters: {'product': productId},
    );
    return CanReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> createReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    final response = await apiClient.dio.post(
      '/reviews/',
      data: {
        'product': productId,
        'rating': rating,
        'comment': comment,
      },
    );
    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }
}
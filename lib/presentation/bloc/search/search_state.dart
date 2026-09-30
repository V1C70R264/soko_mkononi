import 'package:e_commerce/domain/entities/product_entity.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

/// First page of a new query loading. Shows a full-screen spinner.
class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProductEntity> products;
  final String query;
  final bool hasMore;
  /// A next-page fetch is in flight. Shows a small spinner at the
  /// bottom of the list instead of replacing the whole screen.
  final bool isLoadingMore;

  SearchLoaded({
    required this.products,
    required this.query,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  SearchLoaded copyWith({
    List<ProductEntity>? products,
    String? query,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SearchLoaded(
      products: products ?? this.products,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
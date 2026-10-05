// lib/presentation/bloc/search/search_state.dart
import 'package:e_commerce/domain/entities/product_entity.dart';
import 'product_feed_type.dart';

/// Per-feed data: what's loaded so far, the cursor for the next page,
/// and whether more pages exist. One of these per tab.
class FeedData {
  final List<ProductEntity> products;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasLoadedOnce;
  final String? errorMessage;

  const FeedData({
    this.products = const [],
    this.nextCursor,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasLoadedOnce = false,
    this.errorMessage,
  });

  FeedData copyWith({
    List<ProductEntity>? products,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadedOnce,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedData(
      products: products ?? this.products,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SearchState {
  final Map<ProductFeedType, FeedData> feeds;
  final ProductFeedType activeFeed;
  /// The current search text, kept so the text field can be restored
  /// if the screen rebuilds — only meaningful for the viewAll feed.
  final String activeQuery;

  const SearchState({
    required this.feeds,
    required this.activeFeed,
    this.activeQuery = '',
  });

  factory SearchState.initial() {
    return const SearchState(
      feeds: {
        ProductFeedType.viewAll: FeedData(),
        ProductFeedType.trending: FeedData(),
        ProductFeedType.newSellers: FeedData(),
      },
      activeFeed: ProductFeedType.viewAll,
    );
  }

  FeedData get activeFeedData => feeds[activeFeed]!;

  SearchState copyWith({
    Map<ProductFeedType, FeedData>? feeds,
    ProductFeedType? activeFeed,
    String? activeQuery,
  }) {
    return SearchState(
      feeds: feeds ?? this.feeds,
      activeFeed: activeFeed ?? this.activeFeed,
      activeQuery: activeQuery ?? this.activeQuery,
    );
  }

  /// Returns a copy with one feed's data replaced.
  SearchState withFeed(ProductFeedType type, FeedData data) {
    final updated = Map<ProductFeedType, FeedData>.from(feeds);
    updated[type] = data;
    return copyWith(feeds: updated);
  }
}
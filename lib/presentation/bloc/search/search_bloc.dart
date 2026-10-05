// lib/presentation/bloc/search/search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';
import 'package:e_commerce/domain/usecases/search_products.dart';
import 'package:e_commerce/domain/usecases/get_trending_products.dart';
import 'package:e_commerce/domain/usecases/get_new_seller_products.dart';
import 'product_feed_type.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProducts searchProducts;
  final GetTrendingProducts getTrendingProducts;
  final GetNewSellerProducts getNewSellerProducts;

  SearchBloc(
    this.searchProducts,
    this.getTrendingProducts,
    this.getNewSellerProducts,
  ) : super(SearchState.initial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SwitchFeed>(_onSwitchFeed);
    on<LoadMoreActiveFeed>(_onLoadMore);
  }

  /// Dispatches the right usecase for a feed type. viewAll uses the
  /// current query text; trending/newSellers ignore the query.
  Future<Result<ProductPageEntity>> _fetch(
    ProductFeedType type,
    String query, {
    String? cursor,
  }) {
    switch (type) {
      case ProductFeedType.viewAll:
        return searchProducts(query, cursor: cursor);
      case ProductFeedType.trending:
        return getTrendingProducts(cursor: cursor);
      case ProductFeedType.newSellers:
        return getNewSellerProducts(cursor: cursor);
    }
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    // A new search term always resets the viewAll feed to page 1,
    // discarding whatever was scrolled before.
    emit(state.copyWith(
      activeFeed: ProductFeedType.viewAll,
      activeQuery: event.query,
      feeds: {
        ...state.feeds,
        ProductFeedType.viewAll: const FeedData(isLoadingMore: false),
      },
    ));

    final result = await _fetch(ProductFeedType.viewAll, event.query);

    result.fold(
      (page) {
        emit(state.withFeed(
          ProductFeedType.viewAll,
          FeedData(
            products: page.products,
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            hasLoadedOnce: true,
          ),
        ));
      },
      (message) {
        emit(state.withFeed(
          ProductFeedType.viewAll,
          FeedData(hasLoadedOnce: true, errorMessage: message),
        ));
      },
    );
  }

  Future<void> _onSwitchFeed(
    SwitchFeed event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(activeFeed: event.feed));

    final current = state.feeds[event.feed]!;
    if (current.hasLoadedOnce) {
      // Already have data (or a known error) for this feed — show it
      // instantly, no network call.
      return;
    }

    final result = await _fetch(event.feed, state.activeQuery);

    result.fold(
      (page) {
        emit(state.withFeed(
          event.feed,
          FeedData(
            products: page.products,
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            hasLoadedOnce: true,
          ),
        ));
      },
      (message) {
        emit(state.withFeed(
          event.feed,
          FeedData(hasLoadedOnce: true, errorMessage: message),
        ));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreActiveFeed event,
    Emitter<SearchState> emit,
  ) async {
    final type = state.activeFeed;
    final current = state.feeds[type]!;

    if (!current.hasMore || current.isLoadingMore || !current.hasLoadedOnce) {
      return;
    }

    emit(state.withFeed(type, current.copyWith(isLoadingMore: true)));

    final result = await _fetch(
      type,
      state.activeQuery,
      cursor: current.nextCursor,
    );

    result.fold(
      (page) {
        emit(state.withFeed(
          type,
          current.copyWith(
            products: [...current.products, ...page.products],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            isLoadingMore: false,
          ),
        ));
      },
      (_) {
        // Keep what's already shown; just stop the bottom spinner.
        emit(state.withFeed(type, current.copyWith(isLoadingMore: false)));
      },
    );
  }
}
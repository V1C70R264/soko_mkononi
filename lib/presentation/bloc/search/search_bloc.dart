import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/search_products.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProducts searchProducts;

  // Transient loading state tied to this bloc's lifetime, not part of
  // SearchState because the UI never needs to render these directly.
  String _currentQuery = '';
  String? _nextCursor;

  SearchBloc(this.searchProducts) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchLoadMore>(_onLoadMore);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    // A new query always starts over: page 1, old results discarded.
    _currentQuery = event.query;
    _nextCursor = null;
    emit(SearchLoading());

    final result = await searchProducts(_currentQuery);

    result.fold(
      (page) {
        _nextCursor = page.nextCursor;
        emit(SearchLoaded(
          products: page.products,
          query: _currentQuery,
          hasMore: page.hasMore,
        ));
      },
      (message) => emit(SearchError(message)),
    );
  }

  Future<void> _onLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    // Guards against: firing while a fetch is already running (fast
    // scrolling can raise several load-more triggers back to back),
    // firing with no next page, or firing before any search has run.
    if (current is! SearchLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await searchProducts(_currentQuery, cursor: _nextCursor);

    result.fold(
      (page) {
        _nextCursor = page.nextCursor;
        emit(SearchLoaded(
          products: [...current.products, ...page.products],
          query: _currentQuery,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ));
      },
      (message) {
        // Keep the products already on screen; just stop the bottom
        // spinner. The user can scroll again to retry.
        emit(current.copyWith(isLoadingMore: false));
      },
    );
  }
}
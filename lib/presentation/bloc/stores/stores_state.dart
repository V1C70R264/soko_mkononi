// lib/presentation/bloc/stores/stores_state.dart
import 'package:e_commerce/domain/entities/store_entity.dart';

enum StoresStatus { initial, loading, loaded, error }

class StoresState {
  final StoresStatus status;
  final List<StoreEntity> stores;
  final String query;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;

  const StoresState({
    this.status = StoresStatus.initial,
    this.stores = const [],
    this.query = '',
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.error,
  });

  StoresState withLoadingMore(bool value) {
    return StoresState(
      status: status,
      stores: stores,
      query: query,
      nextCursor: nextCursor,
      hasMore: hasMore,
      isLoadingMore: value,
      error: error,
    );
  }
}
// lib/presentation/bloc/stores/store_products_state.dart
import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/domain/entities/store_entity.dart';

enum StoreProductsStatus { initial, loading, loaded, error }

class StoreProductsState {
  final StoreProductsStatus status;
  final int? storeId;
  final StoreEntity? store;
  final List<ProductEntity> products;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;

  const StoreProductsState({
    this.status = StoreProductsStatus.initial,
    this.storeId,
    this.store,
    this.products = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.error,
  });

  StoreProductsState withLoadingMore(bool value) {
    return StoreProductsState(
      status: status,
      storeId: storeId,
      store: store,
      products: products,
      nextCursor: nextCursor,
      hasMore: hasMore,
      isLoadingMore: value,
      error: error,
    );
  }
}
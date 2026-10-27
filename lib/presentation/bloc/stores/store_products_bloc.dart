// lib/presentation/bloc/stores/store_products_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_store.dart';
import 'package:e_commerce/domain/usecases/get_store_products.dart';
import 'store_products_event.dart';
import 'store_products_state.dart';

class StoreProductsBloc extends Bloc<StoreProductsEvent, StoreProductsState> {
  final GetStore getStore;
  final GetStoreProducts getStoreProducts;

  StoreProductsBloc(this.getStore, this.getStoreProducts)
      : super(const StoreProductsState()) {
    on<LoadStoreProducts>(_onLoad);
    on<LoadMoreStoreProducts>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadStoreProducts event,
    Emitter<StoreProductsState> emit,
  ) async {
    emit(StoreProductsState(
      status: StoreProductsStatus.loading,
      storeId: event.storeId,
    ));

    // Both requests are independent, so they run together. Awaiting the
    // pair keeps each result's own type, unlike Future.wait on a list.
    final (storeResult, productsResult) = await (
      getStore(event.storeId),
      getStoreProducts(event.storeId),
    ).wait;

    if (state.storeId != event.storeId) return;

    storeResult.fold(
      (store) {
        productsResult.fold(
          (page) => emit(StoreProductsState(
            status: StoreProductsStatus.loaded,
            storeId: event.storeId,
            store: store,
            products: page.products,
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          )),
          (message) => emit(StoreProductsState(
            status: StoreProductsStatus.error,
            storeId: event.storeId,
            error: message,
          )),
        );
      },
      (message) => emit(StoreProductsState(
        status: StoreProductsStatus.error,
        storeId: event.storeId,
        error: message,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreStoreProducts event,
    Emitter<StoreProductsState> emit,
  ) async {
    final current = state;
    if (current.status != StoreProductsStatus.loaded ||
        current.storeId == null ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.withLoadingMore(true));

    final result = await getStoreProducts(
      current.storeId!,
      cursor: current.nextCursor,
    );

    if (state.storeId != current.storeId) return;

    result.fold(
      (page) => emit(StoreProductsState(
        status: StoreProductsStatus.loaded,
        storeId: current.storeId,
        store: current.store,
        products: [...current.products, ...page.products],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      )),
      (_) => emit(current.withLoadingMore(false)),
    );
  }
}
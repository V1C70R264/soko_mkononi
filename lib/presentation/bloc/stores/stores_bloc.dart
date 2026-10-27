// lib/presentation/bloc/stores/stores_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_stores.dart';
import 'stores_event.dart';
import 'stores_state.dart';

class StoresBloc extends Bloc<StoresEvent, StoresState> {
  final GetStores getStores;

  StoresBloc(this.getStores) : super(const StoresState()) {
    on<LoadStores>(_onLoad);
    on<LoadMoreStores>(_onLoadMore);
  }

  Future<void> _onLoad(LoadStores event, Emitter<StoresState> emit) async {
    emit(StoresState(status: StoresStatus.loading, query: event.query));

    final result = await getStores(query: event.query);

    // A newer search may have started while this one was in flight.
    if (state.query != event.query) return;

    result.fold(
      (page) => emit(StoresState(
        status: StoresStatus.loaded,
        query: event.query,
        stores: page.stores,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      )),
      (message) => emit(StoresState(
        status: StoresStatus.error,
        query: event.query,
        error: message,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreStores event,
    Emitter<StoresState> emit,
  ) async {
    final current = state;
    if (current.status != StoresStatus.loaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.withLoadingMore(true));

    final result = await getStores(
      query: current.query,
      cursor: current.nextCursor,
    );

    if (state.query != current.query) return;

    result.fold(
      (page) => emit(StoresState(
        status: StoresStatus.loaded,
        query: current.query,
        stores: [...current.stores, ...page.stores],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      )),
      // Keep what's on screen; just stop the bottom spinner.
      (_) => emit(current.withLoadingMore(false)),
    );
  }
}
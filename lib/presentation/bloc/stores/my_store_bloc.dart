// lib/presentation/bloc/stores/my_store_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/apply_for_store.dart';
import 'package:e_commerce/domain/usecases/get_my_store.dart';
import 'my_store_event.dart';
import 'my_store_state.dart';

class MyStoreBloc extends Bloc<MyStoreEvent, MyStoreState> {
  final GetMyStore getMyStore;
  final ApplyForStore applyForStore;

  MyStoreBloc(this.getMyStore, this.applyForStore)
      : super(const MyStoreState()) {
    on<LoadMyStore>(_onLoad);
    on<SubmitStoreApplication>(_onSubmit);
  }

  Future<void> _onLoad(LoadMyStore event, Emitter<MyStoreState> emit) async {
    emit(const MyStoreState(status: MyStoreStatus.loading));

    final result = await getMyStore();

    result.fold(
      (store) => emit(MyStoreState(status: MyStoreStatus.ready, store: store)),
      (message) =>
          emit(MyStoreState(status: MyStoreStatus.error, error: message)),
    );
  }

  Future<void> _onSubmit(
    SubmitStoreApplication event,
    Emitter<MyStoreState> emit,
  ) async {
    final current = state;
    // Ignore a second tap while one request is already running.
    if (current.status != MyStoreStatus.ready || current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, clearSubmitError: true));

    final result = await applyForStore(
      name: event.name,
      description: event.description,
    );

    result.fold(
      (store) => emit(MyStoreState(status: MyStoreStatus.ready, store: store)),
      // Stay on the form with the user's input intact.
      (message) => emit(
        current.copyWith(isSubmitting: false, submitError: message),
      ),
    );
  }
}
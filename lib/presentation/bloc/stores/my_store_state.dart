// lib/presentation/bloc/stores/my_store_state.dart
import 'package:e_commerce/domain/entities/my_store_entity.dart';

enum MyStoreStatus { initial, loading, ready, error }

class MyStoreState {
  final MyStoreStatus status;

  /// Null while ready means the user has not applied yet.
  final MyStoreEntity? store;

  final bool isSubmitting;

  /// A failure to load the screen.
  final String? error;

  /// A failure to submit the form (for example, a name already taken).
  final String? submitError;

  const MyStoreState({
    this.status = MyStoreStatus.initial,
    this.store,
    this.isSubmitting = false,
    this.error,
    this.submitError,
  });

  MyStoreState copyWith({
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return MyStoreState(
      status: status,
      store: store,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/signin_with_google.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithGoogle signInWithGoogle;

  AuthCubit(this.signInWithGoogle) : super(const AuthState());

  Future<void> googleSignIn() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, authSuccess: false, error: null));

    final result = await signInWithGoogle();

    if (result is Success<User>) {
      emit(
        state.copyWith(
          user: result.data,
          isLoading: false,
          authSuccess: true,
          error: null,
        ),
      );
    } else if (result is Error<User>) {
      emit(
        state.copyWith(
          isLoading: false,
          authSuccess: false,
          error: result.message,
        ),
      );
    }
  }

  void clearAuthSuccess() {
    if (state.authSuccess) {
      emit(state.copyWith(authSuccess: false));
    }
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }
}
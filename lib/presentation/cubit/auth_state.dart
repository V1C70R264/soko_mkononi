import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

const _kUndefined = Object();

class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final bool authSuccess;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.authSuccess = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? authSuccess,
    Object? error = _kUndefined,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      authSuccess: authSuccess ?? this.authSuccess,
      error: identical(error, _kUndefined) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, authSuccess, error];
}

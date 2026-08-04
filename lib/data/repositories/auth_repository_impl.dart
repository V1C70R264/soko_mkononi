import 'package:dio/dio.dart';
import 'package:e_commerce/core/storage/token_storage.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/auth_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/google_auth_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/user_remote_datasource.dart';
import 'package:e_commerce/data/models/user_model.dart';
import 'package:e_commerce/domain/entities/user.dart';
import 'package:e_commerce/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemote;
  final GoogleAuthService googleAuth;
  final UserRemoteDatasource userRemote;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.authRemote,
    required this.googleAuth,
    required this.userRemote,
    TokenStorage? tokenStorage,
  }) : tokenStorage = tokenStorage ?? TokenStorage();

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      await authRemote.login(email: email, password: password);
      final user = await _resolveCurrentUser();
      return Success(user);
    } on DioException catch (e) {
      return Error(_messageFromDio(e, fallback: 'Login failed'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      await authRemote.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      return const Success(null);
    } on DioException catch (e) {
      return Error(_messageFromDio(e, fallback: 'Registration failed'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      await googleAuth.signIn();
      final user = await _resolveCurrentUser();
      return Success(user);
    } on DioException catch (e) {
      return Error(_messageFromDio(e, fallback: 'Google sign-in failed'));
    } catch (e) {
      return Error(e.toString().replaceAll(RegExp(r'^Exception:\s*'), ''));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await authRemote.logout();
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      if (!await tokenStorage.isLoggedIn()) {
        return const Success(null);
      }
      final user = await _resolveCurrentUser();
      return Success(user);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await authRemote.requestPasswordReset(email);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_messageFromDio(e, fallback: 'Failed to request password reset'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await authRemote.verifyOtp(email: email, otp: otp);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_messageFromDio(e, fallback: 'Invalid OTP code'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await authRemote.confirmPasswordReset(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return const Success(null);
    } on DioException catch (e) {
      return Error(_messageFromDio(e, fallback: 'Failed to reset password'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<User> _resolveCurrentUser() async {
    final userModel = await userRemote.fetchUserProfile();
    return _mapUser(userModel);
  }

  User _mapUser(UserModel model) {
    return User(
      id: model.id.toString(),
      email: model.email,
      username: model.username,
      fullName: _buildFullName(model.firstName, model.lastName),
      phoneNumber: model.phoneNumber,
      profileImage: model.profileImage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String? _buildFullName(String? first, String? last) {
    final f = (first ?? '').trim();
    final l = (last ?? '').trim();
    if (f.isEmpty && l.isEmpty) return null;
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }

  String _messageFromDio(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) return data['detail'].toString();
      if (data['message'] != null) return data['message'].toString();
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return fallback;
  }
}

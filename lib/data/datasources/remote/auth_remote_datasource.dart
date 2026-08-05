import 'package:dio/dio.dart';
import 'package:e_commerce/core/constants/api_paths.dart';
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/core/storage/token_storage.dart';
import 'package:e_commerce/data/models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRemoteDatasource({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : apiClient = apiClient ?? ApiClient(storage: tokenStorage),
        tokenStorage = tokenStorage ?? TokenStorage();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      ApiPaths.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    await _persistTokens(response.data);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    await apiClient.dio.post(
      ApiPaths.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
      },
    );
  }

  Future<void> signInWithGoogle({required String idToken}) async {
  // TEMP DEBUG — remove after diagnosing
  print('=== SIGN-IN WITH GOOGLE REQUEST ===');
  print('baseUrl: ${apiClient.dio.options.baseUrl}');
  print('path: ${ApiPaths.googlesignin}');
  print('full url guess: ${apiClient.dio.options.baseUrl}${ApiPaths.googlesignin}');
  print('=== END SIGN-IN WITH GOOGLE REQUEST ===');

  final response = await apiClient.dio.post(
    ApiPaths.googlesignin,
    data: {
      'id_token': idToken,
      'token': idToken,
    },
  );

  await _persistTokens(response.data);
}

  Future<void> logout() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    try {
      if (refreshToken != null) {
        await apiClient.dio.post(
          ApiPaths.logout,
          data: {'refresh': refreshToken},
        );
      }
    } on DioException catch (e) {
      // Clear local session even if server logout fails (expired token, etc.)
      if (e.response?.statusCode != 401 && e.response?.statusCode != 400) {
        rethrow;
      }
    } finally {
      await tokenStorage.clearTokens();
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await apiClient.dio.post(
        ApiPaths.requestPasswordReset,
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback to requestOtpRequest if main endpoint 404s
        await apiClient.dio.post(
          ApiPaths.requestOtpRequest,
          data: {'email': email},
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await apiClient.dio.post(
        ApiPaths.confirmOtpRequest,
        data: {
          'email': email,
          'otp': otp,
          'code': otp,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await apiClient.dio.post(
          ApiPaths.validateResetToken,
          data: {
            'email': email,
            'token': otp,
            'otp': otp,
          },
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await apiClient.dio.post(
      ApiPaths.confirmPasswordReset,
      data: {
        'email': email,
        'otp': otp,
        'token': otp,
        'password': newPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<UserModel?> parseUserFromAuthResponse(dynamic data) async {
    if (data is! Map<String, dynamic>) return null;

    Map<String, dynamic>? userJson;
    if (data['user'] is Map<String, dynamic>) {
      userJson = data['user'] as Map<String, dynamic>;
    } else if (data['data'] is Map<String, dynamic>) {
      userJson = data['data'] as Map<String, dynamic>;
    } else if (data.containsKey('id') && data.containsKey('email')) {
      userJson = data;
    }

    return userJson != null ? UserModel.fromJson(userJson) : null;
  }

  Future<void> _persistTokens(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected login response');
    }

    final tokens = data['tokens'];
    final access = (data['access'] ??
            (tokens is Map ? tokens['access'] : null) ??
            data['token'])
        ?.toString();
    final refresh = (data['refresh'] ??
            (tokens is Map ? tokens['refresh'] : null))
        ?.toString();

    if (access == null || refresh == null) {
      throw Exception('Login response missing access or refresh token');
    }

    await tokenStorage.saveTokens(access: access, refresh: refresh);
  }
}

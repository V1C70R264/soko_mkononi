import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/core/constants/api_paths.dart';
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/user_model.dart';

abstract class UserRemoteDatasource {
  Future<UserModel> fetchUserProfile();
  Future<UserModel> updateProfileImage(File image);
  Future<UserModel> updateProfileDetails({
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final ApiClient apiClient;

  UserRemoteDatasourceImpl({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<UserModel> fetchUserProfile() async {
    final token = await apiClient.tokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await apiClient.dio.get(ApiPaths.profile);
      return _parseUserResponse(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception(_errorMessage(e, 'Failed to load user profile'));
    }
  }

  @override
  Future<UserModel> updateProfileImage(File image) async {
    final token = await apiClient.tokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please log in again.');
    }

    final fileName = image.path.split(RegExp(r'[/\\]')).last;
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final mimeSubType =
        ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');

    Future<FormData> buildForm(String field) async {
      return FormData.fromMap({
        field: await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: DioMediaType.parse('image/$mimeSubType'),
        ),
      });
    }

    // Backend uploads to Cloudinary and stores the URL — the app sends the
    // file here. After any successful upload, always refetch the full profile
    // so we get the definitive Cloudinary URL (PATCH bodies often omit it).
    final uploadAttempts = <Future<Response<dynamic>> Function()>[
      () async => apiClient.dio.patch(
            ApiPaths.profile,
            data: await buildForm('profile_image'),
          ),
      () async => apiClient.dio.patch(
            ApiPaths.profile,
            data: await buildForm('avatar'),
          ),
      () async => apiClient.dio.put(
            ApiPaths.profile,
            data: await buildForm('profile_image'),
          ),
    ];

    DioException? lastError;

    for (final send in uploadAttempts) {
      try {
        final response = await send();
        if (_isUploadSuccess(response.statusCode)) {
          return fetchUserProfile();
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          throw Exception('Session expired. Please log in again.');
        }
        lastError = e;
      }
    }

    // Last resort: base64 JSON PATCH (some backends accept this format).
    try {
      final bytes = await image.readAsBytes();
      final dataUri =
          'data:image/$mimeSubType;base64,${base64Encode(bytes)}';
      final response = await apiClient.dio.patch(
        ApiPaths.profile,
        data: {'profile_image': dataUri},
      );
      if (_isUploadSuccess(response.statusCode)) {
        return fetchUserProfile();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      lastError = e;
    }

    if (lastError != null) {
      throw Exception(
        _errorMessage(lastError, 'Failed to upload profile image'),
      );
    }

    throw Exception('Failed to upload profile image. Please try again.');
  }

  @override
  Future<UserModel> updateProfileDetails({
    String? username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final token = await apiClient.tokenStorage.getAccessToken();
    if (token == null) throw Exception('No access token found');

    // Build the PATCH body — omit null fields so the backend
    // treats them as untouched (partial update).
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phoneNumber != null) {
      body['phone'] = phoneNumber;
      body['phone_number'] = phoneNumber; // accept both conventions
    }

    try {
      final response = await apiClient.dio.patch(
        ApiPaths.profile,
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseUserResponse(response.data);
      }
      // Some backends return 204 No Content — refetch profile in that case.
      if (response.statusCode == 204) {
        return fetchUserProfile();
      }
      throw Exception('Unexpected status: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception(_errorMessage(e, 'Failed to update profile'));
    }
  }

  bool _isUploadSuccess(int? statusCode) =>
      statusCode == 200 || statusCode == 201 || statusCode == 204;

  UserModel _parseUserResponse(dynamic body) {
    Map<String, dynamic> userJson;
    if (body is Map<String, dynamic>) {
      if (body.containsKey('user') && body['user'] is Map<String, dynamic>) {
        userJson = body['user'] as Map<String, dynamic>;
      } else if (body.containsKey('data') &&
          body['data'] is Map<String, dynamic>) {
        userJson = body['data'] as Map<String, dynamic>;
      } else {
        userJson = body;
      }
    } else {
      throw Exception('Failed to load user profile');
    }
    return UserModel.fromJson(userJson);
  }

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['detail'] != null) {
      return data['detail'].toString();
    }
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback;
  }
}

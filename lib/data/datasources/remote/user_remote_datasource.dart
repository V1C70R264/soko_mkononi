import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/core/constants/api_paths.dart';
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
      throw Exception('No access token found');
    }

    final bytes = await image.readAsBytes();
    final base64Str = base64Encode(bytes);
    final ext = image.path.split('.').last.toLowerCase();
    final mimeSubType = (ext == 'png') ? 'png' : 'jpeg';
    final dataUri = 'data:image/$mimeSubType;base64,$base64Str';

    // 1. Try Base64 Data URI string JSON PATCH (common for OpenAPI string($binary) schemas)
    try {
      final response = await apiClient.dio.patch(
        ApiPaths.profile,
        data: {
          'avatar': dataUri,
          'profile_image': dataUri,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseUserResponse(response.data);
      }
    } catch (_) {}

    // 2. Try raw Base64 string JSON PATCH
    try {
      final response = await apiClient.dio.patch(
        ApiPaths.profile,
        data: {
          'avatar': base64Str,
          'profile_image': base64Str,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseUserResponse(response.data);
      }
    } catch (_) {}

    // 3. Try single multipart file 'avatar'
    try {
      final uri = Uri.parse('${apiClient.dio.options.baseUrl}${ApiPaths.profile}');
      final request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            image.path,
            contentType: MediaType('image', mimeSubType),
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return _parseUserResponse(body);
      }
    } catch (_) {}

    // 4. Try single multipart file 'profile_image'
    try {
      final uri = Uri.parse('${apiClient.dio.options.baseUrl}${ApiPaths.profile}');
      final request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            image.path,
            contentType: MediaType('image', mimeSubType),
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return _parseUserResponse(body);
      }
    } catch (_) {}

    throw Exception('Failed to upload profile image');
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
    return fallback;
  }
}

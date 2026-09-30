// lib/core/network/dio_error_mapper.dart
import 'package:dio/dio.dart';

String messageFromDio(DioException e, {required String fallback}) {
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
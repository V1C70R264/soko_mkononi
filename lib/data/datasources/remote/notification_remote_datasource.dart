// lib/data/datasources/remote/notification_remote_datasource.dart
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;
  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.dio.get('/notifications/');
    // pagination_class = None on the backend, so this is a plain list.
    final results = response.data as List;
    return results
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await apiClient.dio.get('/notifications/unread-count/');
    return response.data['unread_count'] as int;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await apiClient.dio.post('/notifications/$notificationId/mark-read/');
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.dio.post('/notifications/mark-all-read/');
  }
}
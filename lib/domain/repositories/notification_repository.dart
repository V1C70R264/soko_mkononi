// lib/domain/repositories/notification_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications();
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markAsRead(int notificationId);
  Future<Result<void>> markAllAsRead();
}
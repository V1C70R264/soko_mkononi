// lib/domain/usecases/mark_notification_read.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/repositories/notification_repository.dart';

class MarkNotificationRead {
  final NotificationRepository repository;
  MarkNotificationRead(this.repository);

  Future<Result<void>> call(int notificationId) =>
      repository.markAsRead(notificationId);
}
// lib/domain/usecases/mark_all_notifications_read.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/repositories/notification_repository.dart';

class MarkAllNotificationsRead {
  final NotificationRepository repository;
  MarkAllNotificationsRead(this.repository);

  Future<Result<void>> call() => repository.markAllAsRead();
}
// lib/domain/usecases/get_unread_notification_count.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/repositories/notification_repository.dart';

class GetUnreadNotificationCount {
  final NotificationRepository repository;
  GetUnreadNotificationCount(this.repository);

  Future<Result<int>> call() => repository.getUnreadCount();
}
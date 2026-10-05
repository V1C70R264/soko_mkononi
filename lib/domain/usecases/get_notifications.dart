// lib/domain/usecases/get_notifications.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/notification_entity.dart';
import 'package:e_commerce/domain/repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;
  GetNotifications(this.repository);

  Future<Result<List<NotificationEntity>>> call() =>
      repository.getNotifications();
}
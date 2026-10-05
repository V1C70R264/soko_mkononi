// lib/domain/entities/notification_entity.dart
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String notificationType;
  final String title;
  final String body;
  final int? orderId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.orderId,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, notificationType, title, body, orderId, isRead, createdAt];
}
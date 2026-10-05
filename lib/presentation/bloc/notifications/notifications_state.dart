// lib/presentation/bloc/notifications/notifications_state.dart
import 'package:e_commerce/domain/entities/notification_entity.dart';

abstract class NotificationsState {
  /// Carried across every state so the bell-icon badge always has a
  /// number to show, even while the full list is loading or failed.
  int get unreadCount;
}

class NotificationsInitial extends NotificationsState {
  @override
  int get unreadCount => 0;
}

class NotificationsLoading extends NotificationsState {
  @override
  final int unreadCount;
  NotificationsLoading(this.unreadCount);
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;

  NotificationsLoaded(this.notifications);

  @override
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsError extends NotificationsState {
  final String message;
  @override
  final int unreadCount;
  NotificationsError(this.message, this.unreadCount);
}
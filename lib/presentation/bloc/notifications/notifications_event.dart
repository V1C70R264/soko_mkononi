// lib/presentation/bloc/notifications/notifications_event.dart
abstract class NotificationsEvent {}

class LoadNotifications extends NotificationsEvent {}

/// Lighter than LoadNotifications — just refreshes the badge count,
/// without reloading (or showing a spinner over) the full list.
class RefreshUnreadCount extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final int notificationId;
  MarkNotificationAsRead(this.notificationId);
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}
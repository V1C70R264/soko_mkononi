// lib/presentation/bloc/notifications/notifications_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_notifications.dart';
import 'package:e_commerce/domain/usecases/get_unread_notification_count.dart';
import 'package:e_commerce/domain/usecases/mark_notification_read.dart';
import 'package:e_commerce/domain/usecases/mark_all_notifications_read.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotifications getNotifications;
  final GetUnreadNotificationCount getUnreadNotificationCount;
  final MarkNotificationRead markNotificationRead;
  final MarkAllNotificationsRead markAllNotificationsRead;

  NotificationsBloc(
    this.getNotifications,
    this.getUnreadNotificationCount,
    this.markNotificationRead,
    this.markAllNotificationsRead,
  ) : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
    on<MarkNotificationAsRead>(_onMarkOneRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading(state.unreadCount));

    final result = await getNotifications();

    result.fold(
      (notifications) => emit(NotificationsLoaded(notifications)),
      (message) => emit(NotificationsError(message, state.unreadCount)),
    );
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await getUnreadNotificationCount();

    result.fold(
      (count) {
        // Only update the badge number; don't disturb whatever list
        // state (Loaded/Error) is currently showing.
        final current = state;
        if (current is NotificationsLoaded) {
          // The count is derived from the list itself, so nothing to do
          // here unless the two have drifted — a fresh LoadNotifications
          // will reconcile them next time it's dispatched.
          return;
        }
        emit(_WithCount(count));
      },
      (_) {}, // a failed background refresh shouldn't disrupt the UI
    );
  }

  Future<void> _onMarkOneRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await markNotificationRead(event.notificationId);
    result.fold(
      (_) => add(LoadNotifications()),
      (message) => emit(NotificationsError(message, state.unreadCount)),
    );
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await markAllNotificationsRead();
    result.fold(
      (_) => add(LoadNotifications()),
      (message) => emit(NotificationsError(message, state.unreadCount)),
    );
  }
}

/// Internal helper state: carries only a badge count, used when we want
/// to update the count without a full notification list in hand (e.g.
/// before LoadNotifications has ever run).
class _WithCount extends NotificationsState {
  @override
  final int unreadCount;
  _WithCount(this.unreadCount);
}
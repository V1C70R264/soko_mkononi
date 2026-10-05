// lib/data/repositories/notification_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/notification_remote_datasource.dart';
import 'package:e_commerce/domain/entities/notification_entity.dart';
import 'package:e_commerce/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return Success(notifications);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load notifications'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Success(count);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load unread count'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> markAsRead(int notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Success(null);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to update notification'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Success(null);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to update notifications'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
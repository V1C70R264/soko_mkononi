// lib/data/repositories/order_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/data/datasources/remote/order_remote_datasource.dart';
import 'package:e_commerce/domain/entities/order_entity.dart';
import 'package:e_commerce/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<OrderEntity>>> getOrders() async {
    try {
      final orders = await remoteDataSource.getOrders();
      return Success(orders);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load orders'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<OrderEntity>> createOrder({
    required int shippingAddressId,
    required List<OrderItemInput> items,
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        shippingAddressId: shippingAddressId,
        items: items,
      );
      return Success(order);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to place order'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<OrderEntity>> cancelOrder(int orderId) async {
    try {
      final order = await remoteDataSource.cancelOrder(orderId);
      return Success(order);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to cancel order'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
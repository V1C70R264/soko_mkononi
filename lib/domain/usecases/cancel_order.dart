// lib/domain/usecases/cancel_order.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/order_entity.dart';
import 'package:e_commerce/domain/repositories/order_repository.dart';

class CancelOrder {
  final OrderRepository repository;
  CancelOrder(this.repository);

  Future<Result<OrderEntity>> call(int orderId) => repository.cancelOrder(orderId);
}
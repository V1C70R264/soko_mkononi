// lib/domain/usecases/get_orders.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/order_entity.dart';
import 'package:e_commerce/domain/repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;
  GetOrders(this.repository);

  Future<Result<List<OrderEntity>>> call() => repository.getOrders();
}
// lib/domain/usecases/create_order.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/order_entity.dart';
import 'package:e_commerce/domain/repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;
  CreateOrder(this.repository);

  Future<Result<OrderEntity>> call({
    required int shippingAddressId,
    required List<OrderItemInput> items,
  }) {
    return repository.createOrder(
      shippingAddressId: shippingAddressId,
      items: items,
    );
  }
}
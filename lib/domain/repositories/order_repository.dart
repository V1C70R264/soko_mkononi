// lib/domain/repositories/order_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/order_entity.dart';

/// What the caller sends to create one line of an order — just enough
/// to identify a product and how many, mirroring what the cart already
/// tracks per item.
class OrderItemInput {
  final int productId;
  final int quantity;
  const OrderItemInput({required this.productId, required this.quantity});
}

abstract class OrderRepository {
  Future<Result<List<OrderEntity>>> getOrders();

  Future<Result<OrderEntity>> createOrder({
    required int shippingAddressId,
    required List<OrderItemInput> items,
  });

  Future<Result<OrderEntity>> cancelOrder(int orderId);
}
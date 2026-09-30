// lib/domain/entities/order_item_entity.dart
import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final int productId;
  final String productImageUrl;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productImageUrl,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props =>
      [id, productId, productImageUrl, productName, quantity, unitPrice, subtotal];
}
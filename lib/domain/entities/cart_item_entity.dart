// lib/domain/entities/cart_item_entity.dart
import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int id;
  final int cartId;
  final int productId;
  final String productName;
  final String productImageUrl;
  final double productPrice;
  final int quantity;
  final double totalPrice;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.quantity,
    required this.totalPrice,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [
        id, cartId, productId, productName, productImageUrl,
        productPrice, quantity, totalPrice, addedAt,
      ];
}
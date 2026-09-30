// lib/data/models/cart_model.dart
import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.items,
    required super.totalPrice,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List;
    return CartModel(
      id: json['id'] as int,
      items: itemsJson
          .map((itemJson) => CartItemModel.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
}
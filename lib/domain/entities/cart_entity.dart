// lib/domain/entities/cart_entity.dart
import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final int id;
  final List<CartItemEntity> items;
  final double totalPrice;

  const CartEntity({
    required this.id,
    required this.items,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, items, totalPrice];
}
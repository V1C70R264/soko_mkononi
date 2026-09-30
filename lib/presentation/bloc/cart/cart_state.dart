// presentation/bloc/cart/cart_state.dart
import 'package:e_commerce/domain/entities/cart_entity.dart';
import 'package:e_commerce/domain/entities/cart_item_entity.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartItemAdded extends CartState {
  final CartItemEntity cartItem;
  CartItemAdded(this.cartItem);
}

class CartLoaded extends CartState {
  final CartEntity cart;
  CartLoaded(this.cart);
}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}
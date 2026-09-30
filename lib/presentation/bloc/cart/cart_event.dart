// presentation/bloc/cart/cart_event.dart
abstract class CartEvent {}

class AddToCartEvent extends CartEvent {
  final int productId;
  final int quantity;
  AddToCartEvent({required this.productId, required this.quantity});
}

class LoadCart extends CartEvent {}

class UpdateCartItemQuantityEvent extends CartEvent {
  final int cartItemId;
  final int quantity;
  UpdateCartItemQuantityEvent({required this.cartItemId, required this.quantity});
}

class RemoveCartItemEvent extends CartEvent {
  final int cartItemId;
  RemoveCartItemEvent(this.cartItemId);
}

class ClearCartEvent extends CartEvent {}
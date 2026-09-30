import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/add_to_cart.dart';
import 'package:e_commerce/domain/usecases/get_cart.dart';
import 'package:e_commerce/domain/usecases/update_cart_item_quantity.dart';
import 'package:e_commerce/domain/usecases/remove_cart_item.dart';
import 'package:e_commerce/domain/usecases/clear_cart.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCart addToCart;
  final GetCart getCart;
  final UpdateCartItemQuantity updateCartItemQuantity;
  final RemoveCartItem removeCartItem;
  final ClearCart clearCart;

  CartBloc(
    this.addToCart,
    this.getCart,
    this.updateCartItemQuantity,
    this.removeCartItem,
    this.clearCart,
  ) : super(CartInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<LoadCart>(_onLoadCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveCartItemEvent>(_onRemoveItem);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCart(
      productId: event.productId,
      quantity: event.quantity,
    );

    result.fold(
      (cartItem) {
        emit(CartItemAdded(cartItem));
        add(LoadCart());
      },
      (errorMessage) => emit(CartError(errorMessage)),
    );
  }

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await getCart();

    result.fold(
      (cart) => emit(CartLoaded(cart)),
      (errorMessage) => emit(CartError(errorMessage)),
    );
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await updateCartItemQuantity(
      cartItemId: event.cartItemId,
      quantity: event.quantity,
    );

    result.fold(
      (_) => add(LoadCart()),
      (errorMessage) => emit(CartError(errorMessage)),
    );
  }

  Future<void> _onRemoveItem(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await removeCartItem(event.cartItemId);

    result.fold(
      (_) => add(LoadCart()),
      (errorMessage) => emit(CartError(errorMessage)),
    );
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await clearCart();

    result.fold(
      (_) => add(LoadCart()),
      (errorMessage) => emit(CartError(errorMessage)),
    );
  }
}
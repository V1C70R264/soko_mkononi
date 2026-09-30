// lib/domain/repositories/cart_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/cart_entity.dart';
import 'package:e_commerce/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Result<CartItemEntity>> addToCart({
    required int productId,
    required int quantity,
  });
  Future<Result<CartEntity>> getCart();
  Future<Result<CartItemEntity>> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  });
  Future<Result<void>> removeCartItem(int cartItemId);
  Future<Result<void>> clearCart();
}
// lib/domain/usecases/update_cart_item_quantity.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/domain/repositories/cart_repository.dart';

class UpdateCartItemQuantity {
  final CartRepository repository;
  UpdateCartItemQuantity(this.repository);

  Future<Result<CartItemEntity>> call({
    required int cartItemId,
    required int quantity,
  }) {
    return repository.updateCartItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }
}
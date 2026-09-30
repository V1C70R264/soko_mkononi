// lib/domain/usecases/add_to_cart.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/domain/repositories/cart_repository.dart';

class AddToCart {
  final CartRepository repository;
  AddToCart(this.repository);

  Future<Result<CartItemEntity>> call({
    required int productId,
    required int quantity,
  }) {
    return repository.addToCart(productId: productId, quantity: quantity);
  }
}
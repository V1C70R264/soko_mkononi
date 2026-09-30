// lib/domain/usecases/remove_cart_item.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/repositories/cart_repository.dart';

class RemoveCartItem {
  final CartRepository repository;
  RemoveCartItem(this.repository);

  Future<Result<void>> call(int cartItemId) {
    return repository.removeCartItem(cartItemId);
  }
}
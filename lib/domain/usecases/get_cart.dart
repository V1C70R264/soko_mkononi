// lib/domain/usecases/get_cart.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/cart_entity.dart';
import 'package:e_commerce/domain/repositories/cart_repository.dart';

class GetCart {
  final CartRepository repository;
  GetCart(this.repository);

  Future<Result<CartEntity>> call() {
    return repository.getCart();
  }
}
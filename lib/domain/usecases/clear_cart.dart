import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/repositories/cart_repository.dart';

class ClearCart {
  final CartRepository repository;
  ClearCart(this.repository);

  Future<Result<void>> call() => repository.clearCart();
}
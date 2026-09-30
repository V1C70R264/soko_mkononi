import 'package:dio/dio.dart';
import 'package:e_commerce/core/network/dio_error_mapper.dart';
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/cart_entity.dart';
import 'package:e_commerce/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/domain/repositories/cart_repository.dart';
import 'package:e_commerce/data/datasources/remote/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<CartItemEntity>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final cartItem = await remoteDataSource.addToCart(
        productId: productId,
        quantity: quantity,
      );
      return Success(cartItem);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to add product to cart'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<CartEntity>> getCart() async {
    try {
      final cart = await remoteDataSource.getCart();
      return Success(cart);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to load cart'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<CartItemEntity>> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final cartItem = await remoteDataSource.updateCartItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      return Success(cartItem);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to update quantity'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> removeCartItem(int cartItemId) async {
    try {
      await remoteDataSource.removeCartItem(cartItemId);
      return const Success(null);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to remove item'));
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<Result<void>> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      return const Success(null);
    } on DioException catch (e) {
      return Error(messageFromDio(e, fallback: 'Failed to clear cart'));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
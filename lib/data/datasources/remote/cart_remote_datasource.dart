import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/cart_item_model.dart';
import 'package:e_commerce/data/models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartItemModel> addToCart({
    required int productId,
    required int quantity,
  });
  Future<CartModel> getCart();
  Future<CartItemModel> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  });
  Future<void> removeCartItem(int cartItemId);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;
  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CartItemModel> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final response = await apiClient.dio.post(
      '/cart-items/',
      data: {'product': productId, 'quantity': quantity},
    );
    return CartItemModel.fromJson(response.data);
  }

  @override
  Future<CartModel> getCart() async {
    final response = await apiClient.dio.get('/cart/');
    return CartModel.fromJson(response.data);
  }

  @override
  Future<CartItemModel> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await apiClient.dio.patch(
      '/cart-items/$cartItemId/',
      data: {'quantity': quantity},
    );
    return CartItemModel.fromJson(response.data);
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    await apiClient.dio.delete('/cart-items/$cartItemId/');
  }

  @override
  Future<void> clearCart() async {
    await apiClient.dio.delete('/cart/clear/');
  }
}
// lib/data/models/cart_item_model.dart
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.cartId,
    required super.productId,
    required super.productName,
    required super.productImageUrl,
    required super.productPrice,
    required super.quantity,
    required super.totalPrice,
    required super.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productDetail = json['product_detail'] as Map<String, dynamic>;
    return CartItemModel(
      id: json['id'] as int,
      cartId: json['cart'] as int,
      productId: json['product'] as int,
      productName: productDetail['name'] as String,
      productImageUrl: productDetail['image'] as String,
      // price arrives as a string ("55000.00") because it's a Django
      // DecimalField — parse with double.parse, not a cast.
      productPrice: double.parse(productDetail['price'] as String),
      quantity: json['quantity'] as int,
      // total_price arrives as a number (int or double) — cast via num.
      totalPrice: (json['total_price'] as num).toDouble(),
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity': quantity,
    };
  }
}
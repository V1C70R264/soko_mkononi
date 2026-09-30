// lib/data/models/order_item_model.dart
import 'package:e_commerce/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productImageUrl,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product'] as int,
      productImageUrl: json['product_image_url'] as String? ?? '',
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      // Decimal fields on the Django model arrive as strings.
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
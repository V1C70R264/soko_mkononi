// lib/data/models/order_model.dart
import 'package:e_commerce/domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.totalAmount,
    required super.createdAt,
    required super.scheduledDeliveryDate,
    required super.recipientName,
    required super.recipientPhone,
    required super.shippingRegion,
    required super.shippingDistrict,
    required super.shippingStreetAddress,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List;
    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      // total_amount is a Decimal on the backend -> arrives as a string.
      totalAmount: double.parse(json['total_amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledDeliveryDate: DateTime.parse(json['scheduled_delivery_date'] as String),
      recipientName: json['recipient_name'] as String,
      recipientPhone: json['recipient_phone'] as String,
      shippingRegion: json['shipping_region'] as String,
      shippingDistrict: json['shipping_district'] as String,
      shippingStreetAddress: json['shipping_street_address'] as String,
      items: itemsJson
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
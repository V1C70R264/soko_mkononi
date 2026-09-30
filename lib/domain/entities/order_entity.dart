// lib/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

class OrderEntity extends Equatable {
  final int id;
  final String orderNumber;
  final String status; // matches Django's OrderStatus values exactly
  final double totalAmount;
  final DateTime createdAt;
  final DateTime scheduledDeliveryDate;
  final String recipientName;
  final String recipientPhone;
  final String shippingRegion;
  final String shippingDistrict;
  final String shippingStreetAddress;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.scheduledDeliveryDate,
    required this.recipientName,
    required this.recipientPhone,
    required this.shippingRegion,
    required this.shippingDistrict,
    required this.shippingStreetAddress,
    required this.items,
  });

  bool get isCompleted => status == 'delivered' || status == 'cancelled';

  @override
  List<Object?> get props => [
        id, orderNumber, status, totalAmount, createdAt, scheduledDeliveryDate,
        recipientName, recipientPhone, shippingRegion, shippingDistrict,
        shippingStreetAddress, items,
      ];
}
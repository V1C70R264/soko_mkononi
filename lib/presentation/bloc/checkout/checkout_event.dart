// lib/presentation/bloc/checkout/checkout_event.dart
import 'package:e_commerce/domain/repositories/order_repository.dart';

abstract class CheckoutEvent {}

class PlaceOrder extends CheckoutEvent {
  final int shippingAddressId;
  final List<OrderItemInput> items;
  PlaceOrder({required this.shippingAddressId, required this.items});
}
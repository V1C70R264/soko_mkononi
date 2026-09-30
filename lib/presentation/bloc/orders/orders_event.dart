// lib/presentation/bloc/orders/orders_event.dart
abstract class OrdersEvent {}

class LoadOrders extends OrdersEvent {}

class CancelOrderEvent extends OrdersEvent {
  final int orderId;
  CancelOrderEvent(this.orderId);
}
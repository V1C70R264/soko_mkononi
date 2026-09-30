// lib/presentation/bloc/orders/orders_state.dart
import 'package:e_commerce/domain/entities/order_entity.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  OrdersLoaded(this.orders);

  List<OrderEntity> get inProgress =>
      orders.where((o) => !o.isCompleted).toList();

  List<OrderEntity> get completed =>
      orders.where((o) => o.isCompleted).toList();
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}
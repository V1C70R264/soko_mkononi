// lib/presentation/bloc/checkout/checkout_state.dart
import 'package:e_commerce/domain/entities/order_entity.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final OrderEntity order;
  CheckoutSuccess(this.order);
}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}
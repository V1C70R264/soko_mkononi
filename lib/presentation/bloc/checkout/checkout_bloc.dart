// lib/presentation/bloc/checkout/checkout_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/create_order.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrder createOrder;

  CheckoutBloc(this.createOrder) : super(CheckoutInitial()) {
    on<PlaceOrder>(_onPlaceOrder);
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final result = await createOrder(
      shippingAddressId: event.shippingAddressId,
      items: event.items,
    );
    result.fold(
      (order) => emit(CheckoutSuccess(order)),
      (message) => emit(CheckoutError(message)),
    );
  }
}
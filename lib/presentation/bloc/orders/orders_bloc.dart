// lib/presentation/bloc/orders/orders_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_orders.dart';
import 'package:e_commerce/domain/usecases/cancel_order.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrders getOrders;
  final CancelOrder cancelOrder;

  OrdersBloc(this.getOrders, this.cancelOrder) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoad);
    on<CancelOrderEvent>(_onCancel);
  }

  Future<void> _onLoad(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    final result = await getOrders();
    result.fold(
      (orders) => emit(OrdersLoaded(orders)),
      (message) => emit(OrdersError(message)),
    );
  }

  Future<void> _onCancel(
    CancelOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await cancelOrder(event.orderId);
    result.fold(
      (_) => add(LoadOrders()),
      (message) => emit(OrdersError(message)),
    );
  }
}
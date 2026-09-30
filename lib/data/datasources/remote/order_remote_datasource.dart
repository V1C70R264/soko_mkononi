// lib/data/datasources/remote/order_remote_datasource.dart
import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/data/models/order_model.dart';
import 'package:e_commerce/domain/repositories/order_repository.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> createOrder({
    required int shippingAddressId,
    required List<OrderItemInput> items,
  });
  Future<OrderModel> cancelOrder(int orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;
  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OrderModel>> getOrders() async {
    // OrderViewSet is paginated (OrderPagination). Following `next`
    // keeps this correct even once a user has enough orders to span
    // multiple pages — same fix as the earlier products bug, applied
    // here from the start instead of discovering it after the fact.
    final allOrders = <OrderModel>[];

    var response = await apiClient.dio.get('/orders/');
    while (true) {
      final results = response.data['results'] as List;
      allOrders.addAll(
        results.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)),
      );

      final next = response.data['next'] as String?;
      if (next == null) break;
      response = await apiClient.dio.get(next);
    }

    return allOrders;
  }

  @override
  Future<OrderModel> createOrder({
    required int shippingAddressId,
    required List<OrderItemInput> items,
  }) async {
    final response = await apiClient.dio.post(
      '/orders/',
      data: {
        'shipping_address_id': shippingAddressId,
        'items': items
            .map((item) => {'product': item.productId, 'quantity': item.quantity})
            .toList(),
      },
    );
    return OrderModel.fromJson(response.data);
  }

  @override
  Future<OrderModel> cancelOrder(int orderId) async {
    final response = await apiClient.dio.post('/orders/$orderId/cancel/');
    return OrderModel.fromJson(response.data);
  }
}
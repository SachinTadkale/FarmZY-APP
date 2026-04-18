import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/orders/data/models/order_model.dart';
import 'package:farmzy/features/orders/data/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final service = OrderService(apiClient);
  return OrderRepository(service);
});

class OrderRepository {
  final OrderService _service;

  OrderRepository(this._service);

  Future<OrderListResponse> getOrders({String? search}) async {
    final response = await _service.getFarmerOrders(search: search);
    return response;
  }

  Future<OrderModel> getOrderById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Order id is required.');
    }
    return _service.getFarmerOrderById(id.trim());
  }

  Future<String> acceptOrder(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Order id is required.');
    }
    return _service.acceptOrder(id.trim());
  }

  Future<String> rejectOrder(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Order id is required.');
    }
    return _service.rejectOrder(id.trim());
  }
}

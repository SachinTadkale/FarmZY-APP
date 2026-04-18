import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/orders/data/models/order_model.dart';

class OrderService {
  final ApiClient _api;

  OrderService(this._api);

  Future<OrderListResponse> getFarmerOrders({
    int page = 1,
    int limit = 30,
    String? status,
    String? search,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final response = await _api.get(
      'orders/farmer/getFarmerOrders',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'sortBy': sortBy,
        'order': order,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid orders response format.');
    }

    return OrderListResponse.fromJson(data);
  }

  Future<OrderModel> getFarmerOrderById(String id) async {
    final response = await _api.get('orders/farmer/getFarmerOrderById/$id');
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid order detail response format.');
    }

    final orderJson = data['data'];
    if (orderJson is! Map<String, dynamic>) {
      throw Exception('Order data is missing in detail response.');
    }

    return OrderModel.fromJson(orderJson);
  }

  Future<String> acceptOrder(String id) async {
    final response = await _api.patch('orders/farmer/$id/accept');
    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Order accepted successfully';
  }

  Future<String> rejectOrder(String id) async {
    final response = await _api.patch('orders/farmer/$id/reject');
    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Order rejected successfully';
  }
}

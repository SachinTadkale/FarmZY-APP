import 'package:farmzy/features/orders/data/models/order_model.dart';
import 'package:farmzy/features/orders/data/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum OrdersFilterTab {
  newOrders,
  active,
  closed,
}

final ordersRefreshProvider = StateProvider<int>((ref) => 0);
final ordersSearchProvider = StateProvider<String>((ref) => '');
final ordersFilterProvider = StateProvider<OrdersFilterTab>(
  (ref) => OrdersFilterTab.newOrders,
);

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  ref.watch(ordersRefreshProvider);
  final selectedFilter = ref.watch(ordersFilterProvider);
  final search = ref.watch(ordersSearchProvider).trim();
  final response = await ref.read(orderRepositoryProvider).getOrders(
        search: search.isEmpty ? null : search,
      );
  final allOrders = response.orders;

  if (selectedFilter == OrdersFilterTab.newOrders) {
    return allOrders.where(_isNewOrder).toList();
  }

  if (selectedFilter == OrdersFilterTab.active) {
    return allOrders.where(_isActiveOrder).toList();
  }

  return allOrders.where(_isClosedOrder).toList();
});

final orderDetailProvider =
    FutureProvider.family<OrderModel, String>((ref, orderId) async {
      return ref.read(orderRepositoryProvider).getOrderById(orderId);
    });

final orderActionControllerProvider =
    StateNotifierProvider<OrderActionController, AsyncValue<String?>>((ref) {
      return OrderActionController(ref);
    });

class OrderActionController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  OrderActionController(this._ref) : super(const AsyncValue.data(null));

  Future<void> acceptOrder(String orderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = await _ref.read(orderRepositoryProvider).acceptOrder(orderId);
      _ref.read(ordersRefreshProvider.notifier).state++;
      _ref.invalidate(orderDetailProvider(orderId));
      return message;
    });
  }

  Future<void> rejectOrder(String orderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = await _ref.read(orderRepositoryProvider).rejectOrder(orderId);
      _ref.read(ordersRefreshProvider.notifier).state++;
      _ref.invalidate(orderDetailProvider(orderId));
      return message;
    });
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

bool _isNewOrder(OrderModel order) {
  return order.orderStatus.toUpperCase() == 'CREATED';
}

bool _isActiveOrder(OrderModel order) {
  const activeStatuses = {
    'ACCEPTED',
    'CONFIRMED',
    'PAYMENT_PENDING',
    'PAYMENT_SUCCESS',
    'PROCESSING',
    'DISPATCHED',
    'IN_TRANSIT',
    'DELIVERED',
  };
  return activeStatuses.contains(order.orderStatus.toUpperCase());
}

bool _isClosedOrder(OrderModel order) {
  const closedStatuses = {
    'COMPLETED',
    'CANCELLED',
    'REJECTED',
  };
  return closedStatuses.contains(order.orderStatus.toUpperCase());
}

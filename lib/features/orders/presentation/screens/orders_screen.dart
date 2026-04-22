import 'dart:async';

import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/orders/presentation/widgets/order_card.dart';
import 'package:farmzy/features/orders/providers/orders_controller.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(ordersSearchProvider),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.isEmpty) {
      ref.read(ordersSearchProvider.notifier).state = '';
      return;
    }

    if (value.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(ordersSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(ordersFilterProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final search = ref.watch(ordersSearchProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      isLoading: ordersAsync.isLoading && ordersAsync.hasValue,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by order ID, product, buyer, or status',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                _OrdersFilterTabs(
                  selectedFilter: selectedFilter,
                  onChanged: (value) {
                    ref.read(ordersFilterProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ordersAsync.when(
              skipLoadingOnReload: true,
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            search.isEmpty
                                ? 'No orders yet'
                                : 'No orders matched your search.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(ordersRefreshProvider.notifier).state++;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () {
                          if (order.id.isEmpty) {
                            return;
                          }
                          context.push('${RouteNames.orders}/${order.id}');
                        },
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: orders.length,
                  ),
                );
              },
              loading: () => const AppLoadingState(
                message: 'Fetching your latest orders...',
              ),
              error: (error, _) => AppErrorState(
                error: error,
                title: 'Unable to load orders',
                onRetry: () {
                  ref.read(ordersRefreshProvider.notifier).state++;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersFilterTabs extends StatelessWidget {
  final OrdersFilterTab selectedFilter;
  final ValueChanged<OrdersFilterTab> onChanged;

  const _OrdersFilterTabs({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabPill(
            title: 'New',
            isSelected: selectedFilter == OrdersFilterTab.newOrders,
            onTap: () => onChanged(OrdersFilterTab.newOrders),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            title: 'Active',
            isSelected: selectedFilter == OrdersFilterTab.active,
            onTap: () => onChanged(OrdersFilterTab.active),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            title: 'Closed',
            isSelected: selectedFilter == OrdersFilterTab.closed,
            onTap: () => onChanged(OrdersFilterTab.closed),
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final foreground = isSelected ? selectedColor : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

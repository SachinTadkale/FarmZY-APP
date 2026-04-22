import 'package:farmzy/features/orders/data/models/order_model.dart';
import 'package:farmzy/features/orders/presentation/widgets/status_badge.dart';
import 'package:farmzy/features/orders/providers/orders_controller.dart';
import 'package:farmzy/core/network/app_network_error.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final actionState = ref.watch(orderActionControllerProvider);

    ref.listen(orderActionControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (message) {
          if (message != null && message.isNotEmpty) {
            AppSnackBar.showSuccess(context, message);
            ref.read(orderActionControllerProvider.notifier).clear();
          }
        },
        error: (error, _) {
          AppSnackBar.showError(context, AppNetworkError.userMessage(error));
        },
      );
    });

    return AppScaffold(
      body: orderAsync.when(
        skipLoadingOnReload: true,
        data: (order) => _OrderDetailView(
          order: order,
          isActionLoading: actionState.isLoading,
          onAccept: () async {
            await ref
                .read(orderActionControllerProvider.notifier)
                .acceptOrder(order.id);
          },
          onReject: () async {
            await ref
                .read(orderActionControllerProvider.notifier)
                .rejectOrder(order.id);
          },
        ),
        loading: () =>
            const AppLoadingState(message: 'Loading order details...'),
        error: (error, stackTrace) => AppErrorState(
          error: error,
          title: 'Unable to load order details',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final OrderModel order;
  final bool isActionLoading;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const _OrderDetailView({
    required this.order,
    required this.isActionLoading,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailSection(
            title: 'Order Info',
            children: [
              _RowLabelValue(label: 'Order ID', value: order.id),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: Text('Status')),
                  StatusBadge(status: order.effectiveOrderStatus),
                ],
              ),
              const SizedBox(height: 10),
              _RowLabelValue(
                label: 'Date',
                value: _formatDate(order.createdAt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailSection(
            title: 'Product Info',
            children: [
              _RowLabelValue(label: 'Product', value: order.product.name),
              const SizedBox(height: 10),
              _RowLabelValue(
                label: 'Quantity',
                value:
                    '${order.snapshot.quantity.toStringAsFixed(0)}${order.product.unit}',
              ),
              const SizedBox(height: 10),
              _RowLabelValue(
                label: 'Price / Unit',
                value: currency.format(order.snapshot.unitPrice),
              ),
              const SizedBox(height: 10),
              _RowLabelValue(
                label: 'Total Price',
                value: currency.format(order.snapshot.finalPrice),
                emphasize: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailSection(
            title: 'Buyer Info',
            children: [
              _RowLabelValue(
                label: 'Company',
                value: order.company?.name.isNotEmpty == true
                    ? order.company!.name
                    : 'NA',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailSection(
            title: 'Payment Info',
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Payment Status')),
                  StatusBadge(status: _effectivePaymentStatus(order)),
                ],
              ),
              const SizedBox(height: 10),
              _RowLabelValue(
                label: 'Amount',
                value: currency.format(order.snapshot.finalPrice),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailSection(
            title: 'Delivery Info',
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Delivery Status')),
                  StatusBadge(status: _effectiveDeliveryStatus(order)),
                ],
              ),
            ],
          ),
          if (_canTakeSellerDecision(order)) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: isActionLoading
                        ? null
                        : () => _confirmReject(context),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isActionLoading ? null : () => onAccept(),
                    child: Text(
                      isActionLoading ? 'Please wait...' : 'Accept Order',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Drag Handle (nice UX)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// Title
              Text(
                'Reject Order?',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 10),

              /// Description
              Text(
                'Are you sure you want to reject this order?\n\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              /// Buttons
              Row(
                children: [
                  /// Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Reject
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext); // ✅ safe pop
                        onReject(); // ✅ call after close
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canTakeSellerDecision(OrderModel order) {
    return order.orderStatus.toUpperCase() == 'CREATED';
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  String _effectivePaymentStatus(OrderModel order) {
    final payment = order.paymentStatus.toUpperCase();
    if (payment == 'INITIATED') return 'PAYMENT_PENDING';
    if (payment == 'PENDING' || payment == 'HELD') return 'PAYMENT_PENDING';
    if (payment == 'SUCCESS' ||
        payment == 'PAID' ||
        payment == 'ESCROWED' ||
        payment == 'RELEASED') {
      return 'PAYMENT_RECEIVED';
    }
    if (payment == 'REFUNDED' || payment == 'FAILED' || payment == 'FROZEN') {
      return 'CANCELLED';
    }
    return payment;
  }

  String _effectiveDeliveryStatus(OrderModel order) {
    final status = order.effectiveOrderStatus;
    if (status == 'SHIPPED') return 'SHIPPED';
    if (status == 'DELIVERED') return 'DELIVERED';
    if (status == 'COMPLETED') return 'COMPLETED';
    if (status == 'CANCELLED') return 'CANCELLED';
    return 'PROCESSING';
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _RowLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _RowLabelValue({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          )
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.right,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

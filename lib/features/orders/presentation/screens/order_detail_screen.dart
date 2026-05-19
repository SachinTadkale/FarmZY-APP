/// Module: Order Detail Screen
/// Purpose: Implements the Order Detail Screen module for the FarmZy mobile app.
/// Note: Documentation-only change; behavior remains unchanged.
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/orders/data/models/order_model.dart';
import 'package:farmzy/features/orders/presentation/widgets/status_badge.dart';
import 'package:farmzy/features/orders/providers/orders_controller.dart';
import 'package:farmzy/features/orders/providers/dispute_controller.dart';
import 'package:farmzy/core/network/app_network_error.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Order Detail Screen.
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  /// Build.
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final actionState = ref.watch(orderActionControllerProvider);
    final disputeState = ref.watch(disputeControllerProvider);

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

    ref.listen(disputeControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (message) {
          if (message != null && message.isNotEmpty) {
            AppSnackBar.showSuccess(context, message);
            ref.read(disputeControllerProvider.notifier).clear();
            Navigator.pop(context); // Auto dismiss dispute bottom sheet
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
          isActionLoading: actionState.isLoading || disputeState.isLoading,
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

/// Order Detail View.
class _OrderDetailView extends ConsumerWidget {
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
  /// Build.
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.locale.languageCode;
    final translatedName = order.product.translations.getTranslatedField('name', lang, original: order.product.name);
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
              _RowLabelValue(label: 'Product', value: translatedName),
              const SizedBox(height: 10),
              _RowLabelValue(
                label: 'Quantity',
                value:
                    '${order.snapshot.quantity.toStringAsFixed(0)} ${order.product.unit}',
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
              if (order.delivery != null) ...[
                const SizedBox(height: 10),
                _RowLabelValue(
                  label: 'Delivery Partner',
                  value: order.delivery?.partner?.name.isNotEmpty == true
                      ? order.delivery!.partner!.name
                      : 'Awaiting assignment',
                ),
                const SizedBox(height: 10),
                _RowLabelValue(
                  label: 'Vehicle',
                  value: order.delivery?.partner != null
                      ? '${order.delivery!.partner!.vehicleType} • ${order.delivery!.partner!.vehicleNumber}'
                      : 'NA',
                ),
                const SizedBox(height: 10),
                _RowLabelValue(
                  label: 'Pickup Verification',
                  value: order.delivery!.pickupOtpVerified ? 'Verified' : 'Pending',
                ),
                const SizedBox(height: 10),
                _RowLabelValue(
                  label: 'Delivery Verification',
                  value: order.delivery!.deliveryOtpVerified ? 'Verified' : 'Pending',
                ),
              ],
            ],
          ),
          if (order.delivery != null) ...[
            const SizedBox(height: 12),
            _DetailSection(
              title: 'Delivery Timeline',
              children: _buildTimeline(order),
            ),
          ],
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
          if (_canRaiseDispute(order)) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isActionLoading
                    ? null
                    : () => _showRaiseDisputeSheet(context, ref),
                icon: const Icon(Icons.gavel_rounded, size: 18),
                label: const Text(
                  'Raise A Dispute',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Confirm Reject.
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

  /// Can Take Seller Decision.
  bool _canTakeSellerDecision(OrderModel order) {
    return order.orderStatus.toUpperCase() == 'CREATED';
  }

  /// Format Date.
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  /// Effective Payment Status.
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

  /// Effective Delivery Status.
  String _effectiveDeliveryStatus(OrderModel order) {
    if (order.delivery != null && order.delivery!.status.isNotEmpty) {
      return order.delivery!.status.toUpperCase();
    }
    final status = order.effectiveOrderStatus;
    if (status == 'SHIPPED') return 'SHIPPED';
    if (status == 'DELIVERED') return 'DELIVERED';
    if (status == 'COMPLETED') return 'COMPLETED';
    if (status == 'CANCELLED') return 'CANCELLED';
    return 'PROCESSING';
  }

  List<Widget> _buildTimeline(OrderModel order) {
    final stages = <Map<String, dynamic>>[
      {'label': 'Order Confirmed', 'done': order.orderStatus.toUpperCase() != 'CREATED'},
      {'label': 'Payment Held', 'done': ['HELD', 'ESCROWED', 'RELEASED', 'SUCCESS', 'PAID'].contains(order.paymentStatus.toUpperCase())},
      {'label': 'Delivery Assigned', 'done': order.delivery != null},
      {'label': 'Picked Up', 'done': order.delivery?.pickupOtpVerified == true || ['PICKED_UP', 'IN_TRANSIT', 'DELIVERED'].contains(order.delivery?.status)},
      {'label': 'In Transit', 'done': ['IN_TRANSIT', 'DELIVERED'].contains(order.delivery?.status)},
      {'label': 'Delivered', 'done': order.delivery?.deliveryOtpVerified == true || order.delivery?.status == 'DELIVERED'},
      {'label': 'Payment Released', 'done': order.paymentStatus.toUpperCase() == 'RELEASED'},
    ];

    return stages
        .map(
          (stage) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  stage['done'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: stage['done'] == true ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(stage['label'] as String)),
              ],
            ),
          ),
        )
        .toList();
  }

  /// Can Raise Dispute.
  bool _canRaiseDispute(OrderModel order) {
    final status = order.orderStatus.toUpperCase();
    return status != 'CREATED' && status != 'CANCELLED' && status != 'REJECTED';
  }

  /// Show Raise Dispute Sheet.
  void _showRaiseDisputeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _RaiseDisputeSheet(
          orderId: order.id,
          isLoading: ref.watch(disputeControllerProvider).isLoading,
          onSubmit: (reason, description) async {
            await ref.read(disputeControllerProvider.notifier).raiseDispute(
                  orderId: order.id,
                  reason: reason,
                  description: description,
                );
          },
        );
      },
    );
  }
}

/// Detail Section.
class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  /// Build.
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

/// Row Label Value.
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
  /// Build.
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

class _RaiseDisputeSheet extends StatefulWidget {
  final String orderId;
  final Future<void> Function(String reason, String description) onSubmit;
  final bool isLoading;

  const _RaiseDisputeSheet({
    required this.orderId,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<_RaiseDisputeSheet> createState() => _RaiseDisputeSheetState();
}

class _RaiseDisputeSheetState extends State<_RaiseDisputeSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  final _descController = TextEditingController();

  final List<String> _reasons = [
    'Payment Delay or Failure',
    'Unreasonable Return Demands',
    'Quality Complaints Dispute',
    'Contract/Price Agreement Violation',
    'Communication Failure',
    'Other Policy Violation',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.gavel_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Raise a Dispute',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Escalate this order to platform administration for arbitration.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: InputDecoration(
                labelText: 'Primary Reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedReason = val;
                });
              },
              validator: (val) => val == null ? 'Please select a reason' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Provide specific details about the dispute...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (val.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSubmit(
                                _selectedReason!,
                                _descController.text.trim(),
                              );
                            }
                          },
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Submit Dispute'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:farmzy/features/orders/data/models/order_model.dart';
import 'package:farmzy/features/orders/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final quantityText = order.snapshot.quantity == 0
        ? '-'
        : '${order.snapshot.quantity.toStringAsFixed(0)} ${order.product.unit}';

    final dateText = _formatDate(order.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Top Row: Product + Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currency.format(order.snapshot.finalPrice),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// 🔹 Second Row: Buyer/Seller + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Buyer: ${_getBuyerName()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: order.effectiveOrderStatus),
              ],
            ),

            const SizedBox(height: 6),

            /// 🔹 Third Row: Meta Info (lightweight)
            Text(
              '$quantityText • $dateText',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBuyerName() {
      return order.company?.name ?? 'Unknown';
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yy').format(dateTime);
  }
}
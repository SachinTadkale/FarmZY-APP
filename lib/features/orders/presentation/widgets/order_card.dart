import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/orders/data/models/order_model.dart';
import 'package:farmzy/features/orders/presentation/widgets/status_badge.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
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
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final quantityText = order.snapshot.quantity == 0
        ? '-'
        : '${order.snapshot.quantity.toStringAsFixed(0)} ${order.product.unit}';

    final lang = context.locale.languageCode;
    final translatedName = order.product.translations.getTranslatedField('name', lang, original: order.product.name);
    final dateText = _formatDate(order.createdAt);

    return GlassContainer(
      borderRadius: 28,
      opacity: 0.05,
      blur: 0,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translatedName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'orders.buyer'.tr(args: [_getBuyerName()]),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currency.format(order.snapshot.finalPrice),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(status: order.effectiveOrderStatus),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  borderRadius: 16,
                  opacity: 0.05,
                  blur: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 8),
                          Text(
                            quantityText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 8),
                          Text(
                            dateText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getBuyerName() {
    return order.company?.name ?? 'orders.unknown'.tr();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yy').format(dateTime);
  }
}

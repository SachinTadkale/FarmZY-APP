/**
 * Module: Transaction Card
 * Purpose: Implements the Transaction Card module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/model/transaction_model.dart';
import '../../data/model/transaction_enums.dart';

/**
 * Transaction Card.
 */
class TransactionCard extends StatelessWidget {
  final TransactionModel txn;

  const TransactionCard({super.key, required this.txn});

/**
 * Short Txn Id.
 */
  String _shortTxnId(String id) {
    if (id.length <= 12) return id;
    return "${id.substring(0, 6)}...${id.substring(id.length - 4)}";
  }

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = txn.direction == TransactionDirection.CREDIT;
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(txn.status.name, colorScheme);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Future: Navigate to details
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusBadge(status: txn.status.name, color: statusColor),
                      Text(
                        _formatDate(txn.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isCredit ? Colors.green : Colors.red)
                              .withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          size: 20,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${"transactions.id_label".tr()}: ${_shortTxnId(txn.transactionId)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: txn.transactionId),
                                    );
                                    AppSnackBar.showSuccess(
                                      context,
                                      "transactions.copied".tr(),
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 14,
                                    color: colorScheme.primary.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(2)}",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isCredit ? Colors.green : Colors.red,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    if (status == "SUCCESS") return Colors.green;
    if (status == "FAILED") return colorScheme.error;
    return colorScheme.outline;
  }

/**
 * Get Title.
 */
  String _getTitle() {
    switch (txn.type) {
      case TransactionType.ESCROW_RELEASE:
        return "transactions.crop_payout".tr();
      case TransactionType.DELIVERY_PAYOUT:
        return "transactions.delivery_payout".tr();
      case TransactionType.ORDER_PAYMENT:
        return "transactions.order_payment".tr();
      default:
        return "transactions.other_transaction".tr();
    }
  }

/**
 * Format Date.
 */
  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }
}

/**
 * Status Badge.
 */
class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "common.status_${status.toLowerCase()}".tr(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

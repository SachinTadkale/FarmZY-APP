import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/model/transaction_model.dart';
import '../../data/model/transaction_enums.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel txn;

  const TransactionCard({super.key, required this.txn});

  String _shortTxnId(String id) {
    if (id.length <= 12) return id;
    return "${id.substring(0, 6)}...${id.substring(id.length - 4)}";
  }

  @override
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
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
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
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
                              .withValues(alpha: 0.08),
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
                                  'ID: ${_shortTxnId(txn.transactionId)}',
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
                                      "Transaction ID copied",
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 14,
                                    color: colorScheme.primary.withValues(alpha: 0.6),
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

  String _getTitle() {
    switch (txn.type) {
      case TransactionType.ESCROW_RELEASE:
        return "Crop Payout";
      case TransactionType.DELIVERY_PAYOUT:
        return "Delivery Payout";
      case TransactionType.ORDER_PAYMENT:
        return "Order Payment";
      default:
        return "Other Transaction";
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
            status,
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

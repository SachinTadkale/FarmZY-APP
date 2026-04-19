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
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final isCredit = txn.direction == TransactionDirection.CREDIT;

    return Container(
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
          /// 🔹 Top Row
          Row(
            children: [
              Expanded(
                child: Text(
                  _getTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "${isCredit ? '+' : '-'} ${currency.format(txn.amount)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// 🔹 Status + ID
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Txn ID: ${_shortTxnId(txn.transactionId)}',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 4),

                    GestureDetector(
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
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              _StatusBadge(status: txn.status.name),
            ],
          ),
          const SizedBox(height: 6),

          /// 🔹 Date
          Text(
            _formatDate(txn.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (txn.type) {
      case TransactionType.ESCROW_RELEASE:
        return "Crop Payment";
      case TransactionType.DELIVERY_PAYOUT:
        return "Delivery Earnings";
      case TransactionType.ORDER_PAYMENT:
        return "Order Payment";
      default:
        return "Transaction";
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd MMM yy, hh:mm a').format(date);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == "SUCCESS";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isSuccess ? Colors.green : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

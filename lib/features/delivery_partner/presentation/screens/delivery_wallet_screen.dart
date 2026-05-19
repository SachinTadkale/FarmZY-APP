import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/features/delivery_partner/data/delivery_models.dart';
import 'package:farmzy/features/delivery_partner/providers/delivery_controller.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DeliveryWalletScreen extends ConsumerWidget {
  const DeliveryWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final walletAsync = ref.watch(deliveryWalletProvider);
    final transactionsAsync = ref.watch(deliveryTransactionsProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Logistics Wallet',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(deliveryWalletProvider);
              ref.invalidate(deliveryTransactionsProvider);
              ref.invalidate(deliveryEarningsSummaryProvider);
            },
          ),
        ],
      ),
      body: walletAsync.when(
        loading: () => const AppLoadingState(message: 'Loading wallet ledger...'),
        error: (err, stack) => AppErrorState(
          error: err.toString(),
          title: 'Unable to retrieve wallet data',
          onRetry: () {
            ref.invalidate(deliveryWalletProvider);
            ref.invalidate(deliveryTransactionsProvider);
            ref.invalidate(deliveryEarningsSummaryProvider);
          },
        ),
        data: (wallet) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(deliveryWalletProvider);
              ref.invalidate(deliveryTransactionsProvider);
              ref.invalidate(deliveryEarningsSummaryProvider);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Premium Gradient Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Escrow & Payout Wallet',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Icon(Icons.security, color: Colors.greenAccent, size: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currency.format(wallet.releasedEarnings),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 38,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total Balance Available for Withdrawal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: wallet.releasedEarnings > 0
                                  ? () => _handleWithdrawal(context, ref, wallet.releasedEarnings)
                                  : null,
                              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                              label: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Breakdowns Row
                Row(
                  children: [
                    Expanded(
                      child: _SmallMetricCard(
                        title: 'Total Earnings',
                        value: currency.format(wallet.totalEarnings),
                        icon: Icons.payments,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SmallMetricCard(
                        title: 'Held in Escrow',
                        value: currency.format(wallet.pendingEarnings),
                        icon: Icons.lock_clock,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Analytics Summary Banner
                Text(
                  'Operations Ledger',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),

                transactionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Failed to load ledger: $err'),
                  data: (txList) {
                    if (txList.isEmpty) {
                      return GlassContainer(
                        borderRadius: AppRadius.card,
                        padding: const EdgeInsets.all(24),
                        opacity: 0.05,
                        blur: 0,
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 36, color: colors.onSurfaceVariant.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            const Text(
                              'No ledger transactions parsed yet.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete delivery jobs to start gaining payouts.',
                              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: txList.map((tx) {
                        final isDebit = tx.direction == 'DEBIT';
                        final displayAmount = (isDebit ? '-' : '+') + currency.format(tx.amount);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDebit
                                      ? Colors.red.withOpacity(0.12)
                                      : Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  isDebit ? Icons.arrow_outward_rounded : Icons.call_received_rounded,
                                  color: isDebit ? Colors.red : Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.type.replaceAll('_', ' '),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                displayAmount,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDebit ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleWithdrawal(BuildContext context, WidgetRef ref, double balance) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Initiate Payout Transfer', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('A payout transfer for your entire available logistics earnings will be dispatched directly to your registered bank account.'),
              const SizedBox(height: 16),
              Text(
                'Amount: ${currency.format(balance)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payout transfer initiated successfully! Funds will reflect in 24-48 hours.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirm Transfer'),
            ),
          ],
        );
      },
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

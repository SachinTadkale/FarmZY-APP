/**
 * Module: Delivery Partner Home Screen
 * Purpose: Implements the Delivery Partner Home Screen module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/features/delivery_partner/providers/delivery_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/**
 * Delivery Partner Home Screen.
 */
class DeliveryPartnerHomeScreen extends ConsumerWidget {
  const DeliveryPartnerHomeScreen({super.key});

  @override
/**
 * Build.
 */
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroCard(
          title: 'Delivery dashboard',
          subtitle: state.isAvailable
              ? 'You are live and ready for new jobs.'
              : 'You are currently offline.',
          color: colors.primary,
        ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          value: state.isAvailable,
          onChanged: (_) =>
              ref.read(deliveryControllerProvider.notifier).toggleAvailability(),
          title: const Text('Toggle availability'),
          subtitle: const Text('Turn this on when you want new delivery jobs.'),
        ),
        const SizedBox(height: 16),
        _MetricRow(
          label: 'Available jobs',
          value: state.availableJobs.toString(),
          icon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 12),
        _MetricRow(
          label: 'Active deliveries',
          value: state.activeDeliveries.toString(),
          icon: Icons.local_shipping_rounded,
        ),
        const SizedBox(height: 12),
        _MetricRow(
          label: 'Earnings',
          value: 'Coming soon',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}

/**
 * Hero Card.
 */
class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}

/**
 * Metric Row.
 */
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.12),
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

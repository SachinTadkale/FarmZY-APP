/**
 * Module: Delivery Jobs Screen
 * Purpose: Implements the Delivery Jobs Screen module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:flutter/material.dart';

/**
 * Delivery Jobs Screen.
 */
class DeliveryJobsScreen extends StatelessWidget {
  const DeliveryJobsScreen({super.key});

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      title: 'Available Jobs',
      subtitle: 'This route can later load jobs from your delivery API.',
      icon: Icons.work_outline_rounded,
    );
  }
}

/**
 * Delivery Deliveries Screen.
 */
class DeliveryDeliveriesScreen extends StatelessWidget {
  const DeliveryDeliveriesScreen({super.key});

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      title: 'Active Deliveries',
      subtitle: 'Track active deliveries, proof of delivery, and status here.',
      icon: Icons.local_shipping_outlined,
    );
  }
}

/**
 * Placeholder Screen.
 */
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

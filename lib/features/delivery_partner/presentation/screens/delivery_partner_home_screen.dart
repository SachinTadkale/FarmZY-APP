import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/delivery_partner/providers/delivery_controller.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DeliveryPartnerHomeScreen extends ConsumerWidget {
  const DeliveryPartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryControllerProvider);
    final controller = ref.read(deliveryControllerProvider.notifier);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);

    if (state.isLoading) {
      return const AppLoadingState(message: 'Loading delivery workspace...');
    }

    if (state.error != null && state.profile == null) {
      return AppErrorState(
        error: state.error!,
        title: 'Unable to load delivery workspace',
        onRetry: controller.bootstrap,
      );
    }

    final earnings = state.activeDeliveries.fold<double>(
      0,
      (sum, item) => sum + item.totalPayout,
    );

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Operations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.isAvailable
                      ? 'You are visible for new delivery assignments.'
                      : 'You are currently offline. Turn availability on for new jobs.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.92)),
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  value: state.isAvailable,
                  onChanged: (_) => controller.toggleAvailability(),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Availability', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    state.profile == null
                        ? 'Profile setup required'
                        : '${state.profile!.vehicleType} • ${state.profile!.vehicleNumber}',
                    style: TextStyle(color: Colors.white.withOpacity(0.84)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(label: 'Available Deliveries', value: state.dashboard.availableJobs.toString(), icon: Icons.work_outline_rounded),
              _MetricCard(label: 'Active Deliveries', value: state.dashboard.activeDeliveries.toString(), icon: Icons.local_shipping_outlined),
              _MetricCard(
                label: 'Live Earnings',
                value: currency.format(earnings),
                icon: Icons.payments_outlined,
                onTap: () => context.push(RouteNames.deliveryWallet),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Available Deliveries', actionLabel: 'Refresh', onAction: controller.refresh),
          const SizedBox(height: 12),
          if (state.availableJobs.isEmpty)
            const _EmptyCard(message: 'No nearby delivery requests right now.')
          else
            ...state.availableJobs.take(3).map((job) => _DeliveryJobCard(
                  title: job.productName,
                  subtitle: '${job.companyName} • ${job.quantity.toStringAsFixed(0)} ${job.unit}',
                  payout: currency.format(job.totalPayout),
                  status: job.status,
                  isUrgent: job.isUrgent,
                  actionLabel: 'Accept',
                  onAction: () => controller.acceptJob(job.id),
                )),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Active Deliveries', actionLabel: 'Refresh', onAction: controller.refresh),
          const SizedBox(height: 12),
          if (state.activeDeliveries.isEmpty)
            const _EmptyCard(message: 'No active deliveries in progress.')
          else
            ...state.activeDeliveries.take(3).map((job) => _DeliveryJobCard(
                  title: job.productName,
                  subtitle: '${job.companyName} • ${job.quantity.toStringAsFixed(0)} ${job.unit}',
                  payout: job.status.replaceAll('_', ' '),
                  status: job.status,
                  actionLabel: job.status == 'ASSIGNED'
                      ? 'Accept Job'
                      : job.status == 'ACCEPTED'
                          ? 'Verify Pickup'
                          : job.status == 'PICKED_UP'
                              ? 'Mark In Transit'
                              : job.status == 'IN_TRANSIT'
                                  ? 'Verify Delivery'
                                  : 'View',
                  onAction: () {
                    if (job.status == 'ASSIGNED') {
                      controller.acceptJob(job.id);
                    } else {
                      _showActionSheet(context, ref, job.id, job.status);
                    }
                  },
                )),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref, String deliveryId, String status) {
    final controller = ref.read(deliveryControllerProvider.notifier);
    final otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status == 'ACCEPTED'
                    ? 'Verify Pickup OTP'
                    : status == 'PICKED_UP'
                        ? 'Start Transit'
                        : 'Verify Delivery OTP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (status == 'ACCEPTED' || status == 'IN_TRANSIT')
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (status == 'ACCEPTED') {
                    await controller.verifyPickup(deliveryId, otpController.text.trim());
                  } else if (status == 'PICKED_UP') {
                    await controller.markInTransit(deliveryId);
                  } else if (status == 'IN_TRANSIT') {
                    await controller.verifyDelivery(deliveryId, otpController.text.trim());
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width > 520 ? 160 : double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 10),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _DeliveryJobCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String payout;
  final String status;
  final bool isUrgent;
  final String actionLabel;
  final VoidCallback onAction;

  const _DeliveryJobCard({
    required this.title,
    required this.subtitle,
    required this.payout,
    required this.status,
    this.isUrgent = false,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('URGENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.red)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(payout, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              Text(status.replaceAll('_', ' '), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/delivery_partner/data/delivery_models.dart';
import 'package:farmzy/features/delivery_partner/providers/delivery_controller.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DeliveryJobsScreen extends ConsumerWidget {
  const DeliveryJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryControllerProvider);
    final controller = ref.read(deliveryControllerProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (state.isLoading) {
      return const AppLoadingState(message: 'Loading nearby delivery jobs...');
    }

    if (state.error != null && state.availableJobs.isEmpty) {
      return AppErrorState(
        error: state.error!,
        title: 'Unable to load delivery jobs',
        onRetry: controller.bootstrap,
      );
    }

    final jobsList = state.availableJobs;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: jobsList.isEmpty ? 1 : jobsList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (jobsList.isEmpty) {
            return const _EmptyJobsCard(message: 'No open unassigned jobs in your area.');
          }

          final job = jobsList[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'LOGISTICS ASSIGNMENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    if (job.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Crop & Quantity Information
                Text(
                  job.productName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.quantity.toStringAsFixed(0)} ${job.unit} • Outbound Cargo',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Route Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 14),
                        Container(
                          width: 2,
                          height: 24,
                          color: colors.outlineVariant,
                        ),
                        Icon(Icons.location_on, color: colors.primary, size: 16),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farmer Pickup',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${job.companyName} HQ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Payout and Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guaranteed Payout',
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currency.format(job.totalPayout),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => controller.acceptJob(job.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Accept Delivery',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DeliveryDeliveriesScreen extends ConsumerWidget {
  const DeliveryDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryControllerProvider);
    final controller = ref.read(deliveryControllerProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (state.isLoading) {
      return const AppLoadingState(message: 'Loading active deliveries...');
    }

    final activeList = state.activeDeliveries;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: activeList.isEmpty ? 1 : activeList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (activeList.isEmpty) {
            return const _EmptyJobsCard(message: 'You have no active deliveries in progress.');
          }

          final job = activeList[index];
          final isAssigned = job.status == 'ASSIGNED';

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAssigned
                            ? Colors.amber.withOpacity(0.12)
                            : colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isAssigned ? 'PENDING ACCEPTANCE' : 'ACTIVE SHIPMENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isAssigned ? Colors.amber.shade800 : colors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    _StatusBadge(status: job.status),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  job.productName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.quantity.toStringAsFixed(0)} ${job.unit} • ${job.companyName}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Interactive Progress Steps
                _ProgressSteps(status: job.status),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Payout & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Payout',
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currency.format(job.totalPayout),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (isAssigned) {
                          controller.acceptJob(job.id);
                        } else {
                          _showFlowAction(context, controller, job.id, job.status);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAssigned ? Colors.orange.shade800 : colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isAssigned
                            ? 'Accept Job'
                            : job.status == 'ACCEPTED'
                                ? 'Verify Pickup'
                                : job.status == 'PICKED_UP'
                                    ? 'Start Transit'
                                    : job.status == 'IN_TRANSIT'
                                        ? 'Verify Delivery'
                                        : 'View',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFlowAction(BuildContext context, DeliveryController controller, String deliveryId, String status) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          status == 'ACCEPTED'
              ? 'Pickup Verification OTP'
              : status == 'IN_TRANSIT'
                  ? 'Delivery Dropoff OTP'
                  : 'Transit Confirmation',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: status == 'PICKED_UP'
            ? const Text('Confirm that this delivery cargo has been verified and is now in transit directly to the company HQ hub.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status == 'ACCEPTED'
                        ? 'Enter the 6-digit OTP code provided by the Farmer to authorize cargo pickup completion.'
                        : 'Enter the 6-digit OTP code provided by the Company hub representative to complete delivery and release payouts.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.lock_clock),
                    ),
                  ),
                ],
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
            child: const Text('Submit OTP'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'ASSIGNED') color = Colors.orange;
    if (status == 'ACCEPTED') color = Colors.blue;
    if (status == 'PICKED_UP') color = Colors.teal;
    if (status == 'IN_TRANSIT') color = Colors.indigo;
    if (status == 'DELIVERED') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  final String status;

  const _ProgressSteps({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    int currentStep = 0;
    if (status == 'ACCEPTED') currentStep = 1;
    if (status == 'PICKED_UP') currentStep = 2;
    if (status == 'IN_TRANSIT') currentStep = 3;
    if (status == 'DELIVERED') currentStep = 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep('Assigned', currentStep >= 0, colors),
        _buildConnector(currentStep >= 1, colors),
        _buildStep('Accepted', currentStep >= 1, colors),
        _buildConnector(currentStep >= 2, colors),
        _buildStep('Picked Up', currentStep >= 2, colors),
        _buildConnector(currentStep >= 3, colors),
        _buildStep('Transit', currentStep >= 3, colors),
        _buildConnector(currentStep >= 4, colors),
        _buildStep('Delivered', currentStep >= 4, colors),
      ],
    );
  }

  Widget _buildStep(String label, bool isReached, ColorScheme colors) {
    return Column(
      children: [
        Icon(
          isReached ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isReached ? Colors.green : colors.onSurfaceVariant.withOpacity(0.4),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isReached ? FontWeight.w800 : FontWeight.normal,
            color: isReached ? colors.onSurface : colors.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isReached, ColorScheme colors) {
    return Expanded(
      child: Container(
        height: 2,
        color: isReached ? Colors.green : colors.outlineVariant.withOpacity(0.5),
        margin: const EdgeInsets.only(bottom: 12),
      ),
    );
  }
}

class _EmptyJobsCard extends StatelessWidget {
  final String message;

  const _EmptyJobsCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 40, color: colors.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

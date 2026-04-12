import 'package:farmzy/features/marketplace/providers/marketplace_provider.dart';
import 'package:farmzy/features/my_crops/providers/my_crops_provider.dart';
import 'package:farmzy/features/profile/providers/profile_provider.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final cropsAsync = ref.watch(myCropsProvider);
    final listingsAsync = ref.watch(myListingsProvider);

    return AppScaffold(
      body: profileAsync.when(
        data: (profile) {
          final cropCount = cropsAsync.asData?.value.length ?? 0;
          final listingCount =
              listingsAsync.asData?.value.listings.length ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      child: Text(profile.initials),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(profile.email),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        Chip(label: Text(profile.verificationStatus)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ProfileMetricCard(
                      title: 'My Crops',
                      value: '$cropCount',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileMetricCard(
                      title: 'My Listings',
                      value: '$listingCount',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _InfoTile(
                title: 'User ID',
                subtitle: profile.userId,
                icon: Icons.badge_outlined,
              ),
              _InfoTile(
                title: 'Email Status',
                subtitle: profile.email == 'Email unavailable'
                    ? 'Not available in current API response'
                    : 'Synced from your authenticated session',
                icon: Icons.email_outlined,
              ),
              _InfoTile(
                title: 'Verification Badge',
                subtitle: profile.verificationStatus == 'VERIFIED'
                    ? 'Your account is currently verified for protected farmer actions.'
                    : 'Verification details are still syncing.',
                icon: Icons.verified_outlined,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString()),
          ),
        ),
      ),
    );
  }
}

class _ProfileMetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileMetricCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

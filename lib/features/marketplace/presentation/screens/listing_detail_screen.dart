import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/features/marketplace/data/models/marketplace_listing.dart';
import 'package:farmzy/features/marketplace/providers/marketplace_provider.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return AppScaffold(
      body: listingAsync.when(
        data: (listing) => _buildContent(context, theme, colors, listing),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => AppErrorState(
          error: e,
          title: 'marketplace.error_load'.tr(),
          onRetry: () => ref.refresh(listingDetailProvider(listingId)),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    MarketplaceListing listing,
  ) {
    final lang = context.locale.languageCode;
    final translatedName = listing.product.translations.getTranslatedField(
      'name',
      lang,
      original: listing.product.name,
    );
    final translatedCategory = listing.product.translations.getTranslatedField(
      'category',
      lang,
      original: listing.product.category,
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'listing_image_${listing.id}',
              child: _buildImage(listing.product.imageUrl),
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translatedName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          translatedCategory,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    _statusBadge(theme, listing.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                _InfoSection(
                  title: 'marketplace.price'.tr(),
                  child: Row(
                    children: [
                      Text(
                        "₹${listing.price.toInt()}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      Text(
                        " / ${listing.product.unit}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'marketplace.available_quantity'.tr(),
                        value: "${listing.quantity} ${listing.product.unit}",
                        icon: Icons.inventory_2_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _InfoCard(
                        label: 'marketplace.min_order'.tr(),
                        value:
                            "${listing.minOrder?.toInt() ?? 0} ${listing.product.unit}",
                        icon: Icons.shopping_basket_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
                _InfoSection(
                  title: 'marketplace.seller_details'.tr(),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.seller.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                listing.location.district ??
                                    listing.location.address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {}, // Future: Call/Chat
                          icon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                _InfoSection(
                  title: 'marketplace.description'.tr(),
                  child: Text(
                    "High quality $translatedName from ${listing.location.district}. Directly from farmer to you. Delivery support available.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Spacing for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String? url) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1)),
      child: url != null && url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover)
          : const Icon(
              Icons.image_not_supported_rounded,
              size: 64,
              color: Colors.grey,
            ),
    );
  }

  Widget _statusBadge(ThemeData theme, String status) {
    final isAvailable = status.toUpperCase() == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.orange).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isAvailable ? Colors.green : Colors.orange).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isAvailable ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

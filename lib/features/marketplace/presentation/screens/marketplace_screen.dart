import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/marketplace/data/models/marketplace_listing.dart';
import 'package:farmzy/features/marketplace/providers/marketplace_provider.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:farmzy/features/my_crops/providers/my_crops_provider.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/app_shimmer.dart';
import 'package:farmzy/shared/widgets/app_empty_state.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/shared/widgets/app_text_field.dart';
import 'package:farmzy/shared/widgets/app_dropdown.dart';
import 'package:farmzy/shared/widgets/app_side_panel.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/premium_search_bar.dart';
import 'package:farmzy/shared/widgets/premium_filter_popup.dart';
import 'package:farmzy/shared/widgets/premium_tab_switcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  Timer? _debounce;
  bool _isPanelLoading = false;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(marketplaceFilterProvider);
    _searchController = TextEditingController(text: filters.search);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final filters = ref.read(marketplaceFilterProvider);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(marketplaceFilterProvider.notifier).state = filters.copyWith(
        search: value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final marketAsync = ref.watch(marketplaceListingsProvider);
    final myListingsAsync = ref.watch(myListingsProvider);
    final filters = ref.watch(marketplaceFilterProvider);

    return AppScaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: _tabController.index == 1
          ? Padding(
              padding: const EdgeInsets.only(bottom: 82),
              child: GlassContainer(
                borderRadius: 999,
                opacity: 0.2,
                blur: 20,
                color: theme.colorScheme.primary,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                padding: EdgeInsets.zero,
                child: IconButton(
                  onPressed: () => _showAddListingPanel(context, ref),
                  icon: _isPanelLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            )
          : null,
      body: Column(
        children: [
          _header(theme, filters),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ListingPane(
                  listingsAsync: marketAsync,
                  emptyMessage: 'marketplace.no_listings'.tr(),
                  onActionPressed: (listing) =>
                      context.push('/marketplace/${listing.id}'),
                  onRetry: () => ref.refresh(marketplaceListingsProvider),
                ),
                _ListingPane(
                  listingsAsync: myListingsAsync,
                  emptyMessage: 'marketplace.no_my_listings'.tr(),
                  onActionPressed: (listing) =>
                      _showManageListingPanel(context, ref, listing),
                  onRetry: () => ref.refresh(myListingsProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, MarketplaceFilterState filters) {
    return GlassContainer(
      borderRadius: 0,
      opacity: 0.05,
      blur: 20,
      border: Border.all(color: Colors.transparent, width: 0),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        8,
      ),
      child: Column(
        children: [
          PremiumSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: 'marketplace.search_hint'.tr(),
            suffix: PremiumFilterPopup(
              selectedCategory: filters.category,
              selectedSort: filters.sortBy,
              categories: const [
                FilterOption(label: 'All Categories', value: ''),
                FilterOption(label: 'Vegetables', value: 'VEGETABLES'),
                FilterOption(label: 'Fruits', value: 'FRUITS'),
                FilterOption(label: 'Grains', value: 'GRAINS'),
                FilterOption(label: 'Milk', value: 'MILK'),
                FilterOption(label: 'Flowers', value: 'FLOWERS'),
              ],
              sortOptions: const [
                FilterOption(label: 'Newest First', value: 'createdAt'),
                FilterOption(label: 'Price: Low to High', value: 'price'),
                FilterOption(label: 'Price: High to Low', value: 'price_desc'),
              ],
              onFiltersChanged: (cat, sort) {
                ref.read(marketplaceFilterProvider.notifier).state = filters
                    .copyWith(category: cat, sortBy: sort);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PremiumTabSwitcher(
            controller: _tabController,
            tabs: [
              'marketplace.marketplace_tab'.tr(),
              'marketplace.my_listings_tab'.tr(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddListingPanel(BuildContext context, WidgetRef ref) async {
    setState(() => _isPanelLoading = true);
    try {
      final products = await ref.read(myCropsProvider.future);
      if (products.isEmpty) {
        if (context.mounted)
          AppSnackBar.showError(context, "Add a crop first.");
        return;
      }

      if (context.mounted) {
        AppSidePanel.show(
          context: context,
          title: 'marketplace.create_listing'.tr(),
          child: _ListingFormPanel(products: products),
        );
      }
    } finally {
      setState(() => _isPanelLoading = false);
    }
  }

  Future<void> _showManageListingPanel(
    BuildContext context,
    WidgetRef ref,
    MarketplaceListing listing,
  ) async {
    setState(() => _isPanelLoading = true);
    try {
      // Simulate/Check if any data needed
      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        AppSidePanel.show(
          context: context,
          title: 'marketplace.manage'.tr(),
          child: _ListingFormPanel(listing: listing),
        );
      }
    } finally {
      setState(() => _isPanelLoading = false);
    }
  }
}

class _ListingFormPanel extends ConsumerStatefulWidget {
  final List<CropProduct>? products;
  final MarketplaceListing? listing;

  const _ListingFormPanel({this.products, this.listing});

  @override
  ConsumerState<_ListingFormPanel> createState() => _ListingFormPanelState();
}

class _ListingFormPanelState extends ConsumerState<_ListingFormPanel> {
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minOrderController;
  CropProduct? _selectedProduct;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.listing?.price.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.listing?.quantity.toString() ?? '',
    );
    _minOrderController = TextEditingController(
      text: widget.listing?.minOrder?.toString() ?? '',
    );
    _selectedProduct = widget.products?.first;
    _selectedStatus = widget.listing?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.listing != null;

    return Column(
      children: [
        if (!isEdit) ...[
          AppDropdown<CropProduct>(
            label: 'Select Crop',
            value: _selectedProduct,
            items: widget.products!
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedProduct = v),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppTextField(
          label: 'Price per Unit',
          controller: _priceController,
          keyboardType: TextInputType.number,
          hint: "e.g. 24",
          prefixIcon: Icons.currency_rupee_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Total Quantity',
          controller: _quantityController,
          keyboardType: TextInputType.number,
          hint: "e.g. 500",
          prefixIcon: Icons.inventory_2_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Minimum Order',
          controller: _minOrderController,
          keyboardType: TextInputType.number,
          hint: "e.g. 50",
          prefixIcon: Icons.shopping_bag_rounded,
        ),
        if (isEdit) ...[
          const SizedBox(height: AppSpacing.lg),
          AppDropdown<String>(
            label: 'Listing Status',
            value: _selectedStatus,
            items: [
              'ACTIVE',
              'CLOSED',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedStatus = v),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          text: isEdit ? 'common.save'.tr() : 'marketplace.publish'.tr(),
          isLoading: ref.watch(listingMutationControllerProvider).isLoading,
          onPressed: () async {
            if (isEdit) {
              await ref
                  .read(listingMutationControllerProvider.notifier)
                  .updateListing(
                    listingId: widget.listing!.id,
                    price: double.parse(_priceController.text),
                    quantity: double.parse(_quantityController.text),
                    minOrder: double.parse(_minOrderController.text),
                    status: _selectedStatus!,
                  );
            } else {
              await ref
                  .read(listingMutationControllerProvider.notifier)
                  .createListing(
                    productId: _selectedProduct!.id,
                    price: double.parse(_priceController.text),
                    quantity: double.parse(_quantityController.text),
                    minOrder: double.parse(_minOrderController.text),
                  );
            }
            if (context.mounted &&
                !ref.read(listingMutationControllerProvider).hasError) {
              Navigator.pop(context);
            }
          },
        ),
        if (isEdit) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'common.delete'.tr(),
            variant: AppButtonVariant.danger,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Listing"),
                  content: const Text(
                    "Are you sure you want to remove this listing from marketplace?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(listingMutationControllerProvider.notifier)
                    .deleteListing(widget.listing!.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ],
    );
  }
}

class _ListingPane extends StatelessWidget {
  final AsyncValue<MarketplaceListingResult> listingsAsync;
  final String emptyMessage;
  final void Function(MarketplaceListing listing)? onActionPressed;
  final VoidCallback onRetry;

  const _ListingPane({
    required this.listingsAsync,
    required this.emptyMessage,
    this.onActionPressed,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return listingsAsync.when(
      data: (result) {
        if (result.listings.isEmpty) {
          return AppEmptyState(
            icon: Icons.storefront_rounded,
            title: 'No listings found',
            subtitle: emptyMessage,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: result.listings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) =>
              _ListingCard(
                    listing: result.listings[index],
                    onTap: () => onActionPressed?.call(result.listings[index]),
                  )
                  .animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideY(begin: 0.1, end: 0),
        );
      },
      loading: () => AppShimmer.list(
        height: 220,
        borderRadius: 32,
        padding: const EdgeInsets.all(20),
      ),
      error: (e, s) => AppErrorState(
        title: 'marketplace.error_load'.tr(),
        error: e,
        onRetry: onRetry,
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;

  const _ListingCard({required this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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

    return GlassContainer(
      borderRadius: 32,
      opacity: 0.05,
      blur: 20,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'listing_image_${listing.id}',
                      child: _image(listing.product.imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  translatedName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              _statusBadge(theme, listing.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$translatedCategory • ${listing.quantity} ${listing.product.unit}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _sellerInfo(theme, listing),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  borderRadius: 20,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _priceInfo(theme, listing),
                      Container(
                        height: 24,
                        width: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      _minOrderInfo(theme, listing),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _image(String? url) {
    return GlassContainer(
      width: 90,
      height: 90,
      borderRadius: 22,
      opacity: 0.1,
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const AppShimmer.rectangular(height: 90),
              )
            : const Icon(Icons.eco_rounded, size: 40),
      ),
    );
  }

  Widget _statusBadge(ThemeData theme, String status) {
    final isActive = status == 'ACTIVE';
    final color = isActive ? Colors.green : Colors.red;
    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: color,
      opacity: 0.15,
      blur: 5,
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sellerInfo(ThemeData theme, MarketplaceListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              listing.seller.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                listing.location.district ??
                    listing.location.state ??
                    "Unknown",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _priceInfo(ThemeData theme, MarketplaceListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PRICE",
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "₹${listing.price}/${listing.product.unit}",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _minOrderInfo(ThemeData theme, MarketplaceListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "MIN ORDER",
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${listing.minOrder ?? 0} ${listing.product.unit}",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

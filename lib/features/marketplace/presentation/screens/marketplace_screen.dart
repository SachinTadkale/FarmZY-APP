import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmzy/features/marketplace/data/models/marketplace_listing.dart';
import 'package:farmzy/features/marketplace/providers/marketplace_provider.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:farmzy/features/my_crops/providers/my_crops_provider.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketAsync = ref.watch(marketplaceListingsProvider);
    final myListingsAsync = ref.watch(myListingsProvider);
    final filters = ref.watch(marketplaceFilterProvider);

    ref.listen(listingMutationControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (message) {
          if (message != null && message.isNotEmpty) {
            AppSnackBar.showSuccess(context, message);
            ref.read(listingMutationControllerProvider.notifier).clear();
          }
        },
        error: (_, __) {
          final message = ref
              .read(listingMutationControllerProvider.notifier)
              .readableError();
          AppSnackBar.showError(context, message ?? 'Unable to update listing.');
        },
      );
    });

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddListingSheet(context, ref),
          icon: const Icon(Icons.add_business_outlined),
          label: const Text('Add Listing'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by crop or category',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(marketplaceFilterProvider.notifier).state =
                          filters.copyWith(search: value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: filters.category.isEmpty ? null : filters.category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Vegetable',
                              child: Text('Vegetable'),
                            ),
                            DropdownMenuItem(
                              value: 'Fruit',
                              child: Text('Fruit'),
                            ),
                            DropdownMenuItem(
                              value: 'Grain',
                              child: Text('Grain'),
                            ),
                            DropdownMenuItem(
                              value: 'Pulses',
                              child: Text('Pulses'),
                            ),
                          ],
                          onChanged: (value) {
                            ref.read(marketplaceFilterProvider.notifier).state =
                                filters.copyWith(category: value ?? '');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: filters.sortBy,
                          decoration: const InputDecoration(labelText: 'Sort by'),
                          items: const [
                            DropdownMenuItem(
                              value: 'createdAt',
                              child: Text('Newest'),
                            ),
                            DropdownMenuItem(
                              value: 'price',
                              child: Text('Price'),
                            ),
                          ],
                          onChanged: (value) {
                            ref.read(marketplaceFilterProvider.notifier).state =
                                filters.copyWith(sortBy: value ?? 'createdAt');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Marketplace'),
                Tab(text: 'My Listings'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ListingPane(
                    listingsAsync: marketAsync,
                    emptyMessage:
                        'No marketplace listings match your current filters.',
                    actionLabel: 'Pricing only',
                    onActionPressed: null,
                  ),
                  _ListingPane(
                    listingsAsync: myListingsAsync,
                    emptyMessage:
                        'You have not listed any of your crops in the marketplace yet.',
                    actionLabel: 'Manage',
                    onActionPressed: (listing) =>
                        _showManageListingSheet(context, ref, listing),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddListingSheet(BuildContext context, WidgetRef ref) async {
    final products = await ref.read(myCropsProvider.future);

    if (products.isEmpty) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          'Add a crop in My Crops first. Only your own products can be listed.',
        );
      }
      return;
    }

    CropProduct? selectedProduct = products.first;
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final minOrderController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Listing from My Crops',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CropProduct>(
                    value: selectedProduct,
                    decoration: const InputDecoration(labelText: 'My crop'),
                    items: products
                        .map(
                          (crop) => DropdownMenuItem(
                            value: crop,
                            child: Text('${crop.name} • ${crop.unit}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedProduct = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: minOrderController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Minimum order'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final price = double.tryParse(priceController.text.trim());
                        final quantity =
                            double.tryParse(quantityController.text.trim());
                        final minOrder =
                            double.tryParse(minOrderController.text.trim());

                        if (selectedProduct == null ||
                            price == null ||
                            quantity == null ||
                            minOrder == null) {
                          AppSnackBar.showError(
                            context,
                            'Select your crop and enter valid pricing details.',
                          );
                          return;
                        }

                        await ref
                            .read(listingMutationControllerProvider.notifier)
                            .createListing(
                              productId: selectedProduct!.id,
                              price: price,
                              quantity: quantity,
                              minOrder: minOrder,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Publish Listing'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showManageListingSheet(
    BuildContext context,
    WidgetRef ref,
    MarketplaceListing listing,
  ) async {
    final priceController = TextEditingController(text: listing.price.toString());
    final quantityController =
        TextEditingController(text: listing.quantity.toString());
    final minOrderController = TextEditingController(
      text: (listing.minOrder ?? 0).toString(),
    );
    var selectedStatus = listing.status;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage ${listing.product.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: minOrderController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Minimum order'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'ACTIVE',
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: 'CLOSED',
                        child: Text('Closed'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedStatus = value ?? 'ACTIVE');
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(listingMutationControllerProvider.notifier)
                                .deleteListing(listing.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Cancel Listing'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final price =
                                double.tryParse(priceController.text.trim());
                            final quantity =
                                double.tryParse(quantityController.text.trim());
                            final minOrder =
                                double.tryParse(minOrderController.text.trim());

                            if (price == null ||
                                quantity == null ||
                                minOrder == null) {
                              AppSnackBar.showError(
                                context,
                                'Enter valid price, quantity, and min order.',
                              );
                              return;
                            }

                            await ref
                                .read(listingMutationControllerProvider.notifier)
                                .updateListing(
                                  listingId: listing.id,
                                  price: price,
                                  quantity: quantity,
                                  minOrder: minOrder,
                                  status: selectedStatus,
                                );

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ListingPane extends StatelessWidget {
  final AsyncValue<MarketplaceListingResult> listingsAsync;
  final String emptyMessage;
  final String actionLabel;
  final void Function(MarketplaceListing listing)? onActionPressed;

  const _ListingPane({
    required this.listingsAsync,
    required this.emptyMessage,
    required this.actionLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return listingsAsync.when(
      data: (result) {
        if (result.listings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(emptyMessage, textAlign: TextAlign.center),
            ),
          );
        }

        final currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ');

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: result.listings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final listing = result.listings[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: listing.product.imageUrl != null &&
                                  listing.product.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: listing.product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const _ListingImagePlaceholder(),
                                )
                              : const _ListingImagePlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${listing.product.category} • ${listing.product.unit}',
                            ),
                            const SizedBox(height: 4),
                            Text('Seller: ${listing.seller.name}'),
                          ],
                        ),
                      ),
                      Chip(label: Text(listing.status)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DetailChip(
                        label: 'Price',
                        value: currency.format(listing.price),
                      ),
                      _DetailChip(
                        label: 'Location',
                        value: listing.location.district ??
                            listing.location.state ??
                            listing.location.address,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error.toString(), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final String value;

  const _DetailChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _ListingImagePlaceholder extends StatelessWidget {
  const _ListingImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      child: Icon(
        Icons.storefront_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

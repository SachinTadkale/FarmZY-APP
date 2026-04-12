import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:farmzy/features/my_crops/providers/my_crops_provider.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class MyCropsScreen extends ConsumerWidget {
  const MyCropsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(myCropsProvider);

    ref.listen(cropMutationControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (message) {
          if (message != null && message.isNotEmpty) {
            AppSnackBar.showSuccess(context, message);
            ref.read(cropMutationControllerProvider.notifier).clear();
          }
        },
        error: (_, __) {
          final message =
              ref.read(cropMutationControllerProvider.notifier).readableError();
          AppSnackBar.showError(context, message ?? 'Unable to update crops.');
        },
      );
    });

    return AppScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCropSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your crops',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) =>
                  ref.read(myCropsSearchProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: cropsAsync.when(
              data: (crops) {
                if (crops.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No crops added yet. Add your first product to start creating marketplace listings.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(myCropsRefreshProvider.notifier).state++;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return _CropCard(
                        crop: crop,
                        onEdit: () => _showCropSheet(context, ref, crop: crop),
                        onDelete: () => _confirmDelete(context, ref, crop),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: crops.length,
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CropProduct crop,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Remove ${crop.name} from your crop inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(cropMutationControllerProvider.notifier)
          .deleteCrop(crop.id);
    }
  }

  Future<void> _showCropSheet(
    BuildContext context,
    WidgetRef ref, {
    CropProduct? crop,
  }) async {
    final nameController = TextEditingController(text: crop?.name ?? '');
    final categoryController = TextEditingController(text: crop?.category ?? '');
    final unitController = TextEditingController(text: crop?.unit ?? '');
    XFile? selectedImage;
    final picker = ImagePicker();

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
                    crop == null ? 'Add Crop' : 'Edit Crop',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Crop name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null) {
                        setModalState(() => selectedImage = file);
                      }
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      selectedImage == null
                          ? 'Choose product image'
                          : selectedImage!.name,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final category = categoryController.text.trim();
                        final unit = unitController.text.trim();

                        if (name.isEmpty || category.isEmpty || unit.isEmpty) {
                          AppSnackBar.showError(
                            context,
                            'Name, category, and unit are required.',
                          );
                          return;
                        }

                        if (crop == null) {
                          await ref
                              .read(cropMutationControllerProvider.notifier)
                              .createCrop(
                                name: name,
                                category: category,
                                unit: unit,
                                image: selectedImage,
                              );
                        } else {
                          await ref
                              .read(cropMutationControllerProvider.notifier)
                              .updateCrop(
                                productId: crop.id,
                                name: name,
                                category: category,
                                unit: unit,
                                image: selectedImage,
                              );
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(crop == null ? 'Save Crop' : 'Update Crop'),
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
}

class _CropCard extends StatelessWidget {
  final CropProduct crop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CropCard({
    required this.crop,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: crop.imageUrl != null && crop.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: crop.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _CropPlaceholder(),
                    )
                  : const _CropPlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${crop.category} • ${crop.unit}'),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CropPlaceholder extends StatelessWidget {
  const _CropPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.eco_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

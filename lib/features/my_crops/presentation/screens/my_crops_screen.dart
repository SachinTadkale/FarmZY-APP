import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:farmzy/features/my_crops/providers/my_crops_provider.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_shimmer.dart';
import 'package:farmzy/shared/widgets/app_empty_state.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/shared/widgets/app_side_panel.dart';
import 'package:farmzy/shared/widgets/app_dropdown.dart';
import 'package:farmzy/shared/widgets/app_text_field.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class MyCropsScreen extends ConsumerStatefulWidget {
  const MyCropsScreen({super.key});

  @override
  ConsumerState<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends ConsumerState<MyCropsScreen> {
  bool _isPanelLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cropsAsync = ref.watch(myCropsProvider);

    return AppScaffold(
      extendBodyBehindAppBar: true,
      isLoading: _isPanelLoading,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: GlassContainer(
          borderRadius: 24,
          opacity: 0.9,
          blur: 15,
          color: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: InkWell(
            onTap: () => _showCropPanel(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'my_crops.add_crop'.tr(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ],
            ),
          ),
        ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
      ),
      body: Column(
        children: [
          _header(theme, context),
          Expanded(
            child: cropsAsync.when(
              data: (crops) => crops.isEmpty
                  ? AppEmptyState(
                      icon: Icons.agriculture_rounded,
                      title: 'my_crops.no_crops_title'.tr(),
                      subtitle: 'my_crops.no_crops_subtitle'.tr(),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.refresh(myCropsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                        itemCount: crops.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 20),
                        itemBuilder: (context, index) => _CropCard(
                          crop: crops[index], 
                          onEdit: () => _showCropPanel(context, ref, crops[index]),
                        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0),
                      ),
                    ),
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(height: 20),
                itemBuilder: (_, _) => const AppShimmer.rectangular(height: 110, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32)))),
              ),
              error: (e, s) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "my_crops.title".tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage your produce",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCropPanel(BuildContext context, WidgetRef ref, [CropProduct? crop]) async {
    setState(() => _isPanelLoading = true);
    try {
      final nameController = TextEditingController(text: crop?.name ?? '');
      // If metadata is needed, ensure it's prefetched
      await ref.read(productMetadataProvider.future);
      
      if (context.mounted) {
        AppSidePanel.show(
          context: context,
          title: crop == null ? 'my_crops.add_crop'.tr() : 'my_crops.update_crop'.tr(),
          child: _CropFormPanel(
            crop: crop,
            nameController: nameController,
          ),
        );
      }
    } finally {
      setState(() => _isPanelLoading = false);
    }
  }
}

class _CropFormPanel extends ConsumerStatefulWidget {
  final CropProduct? crop;
  final TextEditingController nameController;

  const _CropFormPanel({this.crop, required this.nameController});

  @override
  ConsumerState<_CropFormPanel> createState() => _CropFormPanelState();
}

class _CropFormPanelState extends ConsumerState<_CropFormPanel> {
  String? _selectedCategory;
  String? _selectedUnit;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.crop?.category;
    _selectedUnit = widget.crop?.unit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataAsync = ref.watch(productMetadataProvider);

    return metadataAsync.when(
      data: (metadata) {
        final categories = metadata.map((e) => e['category'].toString()).toList();
        final allowedUnits = _selectedCategory == null
            ? <String>[]
            : List<String>.from(metadata.firstWhere((e) => e['category'] == _selectedCategory)['allowedUnits']);

        return Column(
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _selectedImage = image);
                }
              },
              child: GlassContainer(
                height: 180,
                width: double.infinity,
                borderRadius: 32,
                opacity: 0.1,
                blur: 20,
                padding: EdgeInsets.zero,
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                      )
                    : (widget.crop?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: CachedNetworkImage(imageUrl: widget.crop!.imageUrl!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 40),
                              const SizedBox(height: 12),
                              Text('my_crops.choose_image'.tr(), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          )),
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'my_crops.name_label'.tr(),
              controller: widget.nameController,
              hint: "e.g. Alphonso Mango",
            ),
            const SizedBox(height: 24),
            AppDropdown<String>(
              label: 'Category',
              value: _selectedCategory,
              hint: "Select Category",
              items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCategory = v;
                  _selectedUnit = null; // Reset unit on category change
                });
              },
            ),
            const SizedBox(height: 24),
            AppDropdown<String>(
              label: 'Unit',
              value: _selectedUnit,
              hint: _selectedCategory == null ? "Select Category first" : "Select Unit",
              items: allowedUnits.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: _selectedCategory == null ? null : (v) => setState(() => _selectedUnit = v),
            ),
            const SizedBox(height: 48),
            AppButton(
              text: widget.crop == null ? 'my_crops.save_crop'.tr() : 'my_crops.update_crop'.tr(),
              isLoading: ref.watch(cropMutationControllerProvider).isLoading,
              onPressed: () async {
                if (widget.nameController.text.isEmpty || _selectedCategory == null || _selectedUnit == null) {
                  AppSnackBar.showError(context, 'my_crops.errors.required_fields'.tr());
                  return;
                }

                if (widget.crop == null) {
                  await ref.read(cropMutationControllerProvider.notifier).createCrop(
                        name: widget.nameController.text,
                        category: _selectedCategory!,
                        unit: _selectedUnit!,
                        image: _selectedImage,
                      );
                } else {
                  await ref.read(cropMutationControllerProvider.notifier).updateCrop(
                        productId: widget.crop!.id,
                        name: widget.nameController.text,
                        category: _selectedCategory!,
                        unit: _selectedUnit!,
                        image: _selectedImage,
                      );
                }

                if (context.mounted && !ref.read(cropMutationControllerProvider).hasError) {
                  Navigator.pop(context);
                }
              },
            ),
            if (widget.crop != null) ...[
              const SizedBox(height: 16),
              AppButton(
                text: 'my_crops.delete_crop'.tr(),
                isOutlined: true,
                color: Colors.red,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('my_crops.delete_confirm_title'.tr()),
                      content: Text('my_crops.delete_confirm_msg'.tr()),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('common.cancel'.tr())),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref.read(cropMutationControllerProvider.notifier).deleteCrop(widget.crop!.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) => Center(child: Text(e.toString())),
    );
  }
}

class _CropCard extends StatelessWidget {
  final CropProduct crop;
  final VoidCallback onEdit;

  const _CropCard({required this.crop, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    // Attempt to localize the category name if it exists in translations
    final translatedCategory = 'category.${crop.category.toLowerCase()}'.tr();
    final displayCategory = translatedCategory.contains('category.') ? crop.category : translatedCategory;

    return GlassContainer(
      borderRadius: 32,
      opacity: 0.1,
      blur: 20,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GlassContainer(
                  width: 76,
                  height: 76,
                  borderRadius: 24,
                  opacity: 0.1,
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: crop.imageUrl != null 
                        ? CachedNetworkImage(imageUrl: crop.imageUrl!, fit: BoxFit.cover) 
                        : Icon(Icons.eco_rounded, color: colors.primary, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$displayCategory • ${crop.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _statusBadge(theme, crop.isListed ? 'my_crops.listed_badge'.tr() : 'UNLISTED'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(ThemeData theme, String label) {
    final isListed = label == 'my_crops.listed_badge'.tr() || label == 'LISTED';
    final color = isListed ? Colors.green : theme.colorScheme.primary;
    
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 14,
      opacity: 0.1,
      blur: 5,
      color: color,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

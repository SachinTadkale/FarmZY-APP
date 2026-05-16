import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/core/theme/app_spacing.dart';

class KycUploadBox extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool isDisabled;
  final String? disabledLabel;

  const KycUploadBox({
    super.key,
    required this.label,
    this.image,
    required this.onTap,
    this.onRemove,
    this.isDisabled = false,
    this.disabledLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (isDisabled) {
      return GlassContainer(
        height: 120,
        borderRadius: AppRadius.card,
        opacity: 0.03,
        blur: 10,
        child: Center(
          child: Text(
            disabledLabel ?? 'onboarding.back_not_required'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        height: 120,
        borderRadius: AppRadius.card,
        opacity: image != null ? 0.1 : 0.05,
        blur: 20,
        border: Border.all(
          color: image != null ? colors.primary : Colors.white.withValues(alpha: 0.1),
          width: image != null ? 2.0 : 1.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card - 1),
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image!, fit: BoxFit.cover),
                    Container(color: Colors.black.withValues(alpha: 0.3)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        borderRadius: 8,
                        opacity: 0.4,
                        blur: 10,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'common.uploaded'.tr(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      color: colors.primary.withValues(alpha: 0.8),
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

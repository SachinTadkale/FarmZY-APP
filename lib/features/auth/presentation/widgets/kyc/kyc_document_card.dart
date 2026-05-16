import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/shared/widgets/app_text_field.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'kyc_upload_box.dart';

class KycDocumentCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? docType;
  final Widget? typeDropdown;
  final TextEditingController numberController;
  final String numberLabel;
  final String? numberHint;
  final File? frontImage;
  final File? backImage;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;
  final VoidCallback? onRemoveFront;
  final VoidCallback? onRemoveBack;
  final bool isBackRequired;

  const KycDocumentCard({
    super.key,
    this.title,
    this.subtitle,
    this.docType,
    this.typeDropdown,
    required this.numberController,
    required this.numberLabel,
    this.numberHint,
    this.frontImage,
    this.backImage,
    required this.onPickFront,
    required this.onPickBack,
    this.onRemoveFront,
    this.onRemoveBack,
    this.isBackRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null) ...[
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
          if (typeDropdown != null) ...[
            typeDropdown!,
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            controller: numberController,
            label: numberLabel,
            hint: numberHint,
            textCapitalization: TextCapitalization.characters,
            prefixIcon: Icons.badge_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: KycUploadBox(
                  label: 'onboarding.upload_front'.tr(),
                  image: frontImage,
                  onTap: onPickFront,
                  onRemove: onRemoveFront,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KycUploadBox(
                  label: 'onboarding.upload_back'.tr(),
                  image: backImage,
                  onTap: onPickBack,
                  onRemove: onRemoveBack,
                  isDisabled: !isBackRequired,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

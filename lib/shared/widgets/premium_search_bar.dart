import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';

class PremiumSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final Widget? suffix;
  final VoidCallback? onTap;
  final bool readOnly;

  const PremiumSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText,
    this.suffix,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GlassContainer(
      borderRadius: AppRadius.input,
      opacity: 0.08,
      blur: 20,
      border: Border.all(
        color: colors.outline.withValues(alpha: 0.2),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.1,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.3),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

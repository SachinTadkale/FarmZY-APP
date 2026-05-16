import 'package:farmzy/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.prefixIcon,
    this.enabled = true,
  });

  void _showPicker(BuildContext context) {
    if (!enabled) return;
    
    AppBottomSheet.show(
      context: context,
      title: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item.value == value;
          return ListTile(
            onTap: () {
              onChanged?.call(item.value);
              Navigator.pop(context);
            },
            leading: isSelected 
                ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                : const Icon(Icons.circle_outlined, color: Colors.white24),
            title: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              child: item.child,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              fontSize: 12,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: GlassContainer(
            borderRadius: AppRadius.input,
            opacity: 0.08,
            blur: 25,
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 16,
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(
                      prefixIcon,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: value != null
                        ? DefaultTextStyle(
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            child: items.firstWhere((e) => e.value == value).child,
                          )
                        : Text(
                            hint ?? 'Select ${label.toLowerCase()}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

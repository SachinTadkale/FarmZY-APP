import 'package:farmzy/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';

class FilterOption {
  final String label;
  final String value;
  final IconData? icon;

  const FilterOption({required this.label, required this.value, this.icon});
}

class PremiumFilterPopup extends StatelessWidget {
  final List<FilterOption> categories;
  final List<FilterOption> sortOptions;
  final String selectedCategory;
  final String selectedSort;
  final Function(String category, String sort) onFiltersChanged;
  final Widget child;

  const PremiumFilterPopup({
    super.key,
    required this.categories,
    required this.sortOptions,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onFiltersChanged,
    required this.child,
  });

  void _showFilterSheet(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      title: "Filter & Sort",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("CATEGORIES", context),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: categories.map((e) => _buildChip(
              e.label, 
              e.value == selectedCategory, 
              () {
                onFiltersChanged(e.value, selectedSort);
                Navigator.pop(context);
              },
              context,
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle("SORT BY", context),
          const SizedBox(height: AppSpacing.md),
          ...sortOptions.map((e) => _buildListItem(
            e.label, 
            e.value == selectedSort, 
            () {
              onFiltersChanged(selectedCategory, e.value);
              Navigator.pop(context);
            },
            context,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: AppRadius.button,
        opacity: isSelected ? 0.2 : 0.05,
        color: isSelected ? theme.colorScheme.primary : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String label, bool isSelected, VoidCallback onTap, BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected 
        ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20)
        : null,
    );
  }
}

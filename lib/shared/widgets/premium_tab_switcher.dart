import 'package:flutter/material.dart';

class PremiumTabSwitcher extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const PremiumTabSwitcher({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TabBar(
      controller: controller,
      labelColor: colors.primary,
      unselectedLabelColor: colors.onSurfaceVariant.withValues(alpha: 0.5),
      indicatorColor: colors.primary,
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        letterSpacing: 1.0,
      ),
      unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        letterSpacing: 1.0,
      ),
      tabs: tabs.map((text) => Tab(text: text.toUpperCase())).toList(),
    );
  }
}

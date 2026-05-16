library main_layout;

/// Module: Main Layout
/// Purpose: Implements the Main Layout module for the FarmZy mobile app.
/// Note: Documentation-only change; behavior remains unchanged.
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/app_drawer.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farmzy/features/settings/providers/app_config_provider.dart';

import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Main Layout.
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  /// Build.
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final role = ref.watch(authControllerProvider.select((state) => state.role));
    final location = GoRouterState.of(context).uri.path;

    final appConfig = ref.watch(appConfigProvider).config;

    final allItems = role == UserRole.deliveryPartner
        ? [
            _NavDestination(RouteNames.deliveryHome, Icons.home_outlined, Icons.home, 'navigation.home'.tr()),
            _NavDestination(RouteNames.deliveryJobs, Icons.work_outline, Icons.work, 'navigation.jobs'.tr(), featureKey: 'delivery'),
            _NavDestination(RouteNames.deliveryDeliveries, Icons.local_shipping_outlined, Icons.local_shipping, 'navigation.active'.tr(), featureKey: 'delivery'),
            _NavDestination(RouteNames.profile, Icons.person_outline, Icons.person, 'navigation.profile'.tr()),
          ]
        : [
            _NavDestination(RouteNames.farmerHome, Icons.home_outlined, Icons.home, 'navigation.home'.tr()),
            _NavDestination(RouteNames.marketplace, Icons.store_outlined, Icons.store, 'navigation.marketplace'.tr(), featureKey: 'marketplace'),
            _NavDestination(RouteNames.orders, Icons.shopping_cart_outlined, Icons.shopping_cart, 'navigation.orders'.tr(), featureKey: 'orders'),
            _NavDestination(RouteNames.profile, Icons.person_outline, Icons.person, 'navigation.profile'.tr()),
          ];

    // Filter items based on backend-driven visibility
    final items = allItems.where((item) {
      if (item.featureKey == null) return true;
      return appConfig.isVisible(item.featureKey!);
    }).toList();

    final currentIndex = items.indexWhere((item) => location.startsWith(item.path));
    final selectedIndex = currentIndex == -1 ? 0 : currentIndex;

    return AppScaffold(
      canPop: false,
      onBackBlocked: selectedIndex == 0 ? null : () => context.go(items[0].path),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'FarmZY',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1,
            color: colors.primary,
          ),
        ),
        actions: [
          GlassContainer(
            borderRadius: 99,
            blur: 20,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.notifications_none_rounded, size: 24),
          ).animate().fadeIn().scale(),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GlassContainer(
            borderRadius: 32,
            blur: 40,
            opacity: 0.2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                final isSelected = selectedIndex == index;
                final item = items[index];

                return GestureDetector(
                  onTap: () => context.go(item.path),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 20 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? colors.primary : colors.onSurfaceVariant,
                          size: 24,
                        ).animate(target: isSelected ? 1 : 0).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              curve: Curves.easeOutBack,
                            ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ).animate().fadeIn().slideX(begin: 0.2, end: 0),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nav Destination.
class _NavDestination {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? featureKey;

  const _NavDestination(
    this.path,
    this.icon,
    this.activeIcon,
    this.label, {
    this.featureKey,
  });
}

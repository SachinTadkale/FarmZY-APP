import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/feature_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final isDelivery = authState.role == UserRole.deliveryPartner;

    return Container(
      width: MediaQuery.of(context).size.width * 1,
      height: double.infinity,
      decoration: BoxDecoration(color: colors.surface.withValues(alpha: 0.1)),
      child: Stack(
        children: [
          // Modern Dark Backdrop Overlay (Lag-Free with Light Blur)
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, theme),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xl),

                        if (isDelivery) ...[
                          _SectionLabel(label: 'navigation.main'.tr()),
                          const SizedBox(height: AppSpacing.sm),
                          _DrawerItem(
                            icon: Icons.dashboard_outlined,
                            activeIcon: Icons.dashboard_rounded,
                            title: 'navigation.home'.tr(),
                            onTap: () =>
                                _navigate(context, RouteNames.deliveryHome),
                          ),
                          _DrawerItem(
                            icon: Icons.local_shipping_outlined,
                            activeIcon: Icons.local_shipping_rounded,
                            title: 'navigation.jobs'.tr(),
                            onTap: () =>
                                _navigate(context, RouteNames.deliveryJobs),
                          ),
                          _DrawerItem(
                            icon: Icons.assignment_outlined,
                            activeIcon: Icons.assignment_rounded,
                            title: 'navigation.active'.tr(),
                            onTap: () =>
                                _navigate(context, RouteNames.deliveryDeliveries),
                          ),
                          _DrawerItem(
                            icon: Icons.account_balance_wallet_outlined,
                            activeIcon: Icons.account_balance_wallet_rounded,
                            title: 'Wallet & Earnings',
                            onTap: () =>
                                _navigate(context, RouteNames.deliveryWallet, isPush: true),
                          ),
                          FeatureGuard(
                            featureKey: 'ai',
                            fallbackMode: FeatureGuardMode.disable,
                            child: _DrawerItem(
                              icon: Icons.smart_toy_outlined,
                              activeIcon: Icons.smart_toy_rounded,
                              title: 'navigation.ai'.tr(),
                              onTap: () => _navigate(
                                context,
                                RouteNames.aiChat,
                                isPush: true,
                              ),
                              isAIPowered: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SectionLabel(label: 'navigation.settings'.tr()),
                          const SizedBox(height: AppSpacing.sm),
                          _DrawerItem(
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings_rounded,
                            title: 'settings.title'.tr(),
                            onTap: () => _navigate(
                              context,
                              RouteNames.settings,
                              isPush: true,
                            ),
                          ),
                          _DrawerItem(
                            icon: Icons.help_outline_rounded,
                            activeIcon: Icons.help_rounded,
                            title: 'navigation.help'.tr(),
                            onTap: () =>
                                _navigate(context, RouteNames.help, isPush: true),
                          ),
                        ] else ...[
                          _SectionLabel(label: 'navigation.main'.tr()),
                          const SizedBox(height: AppSpacing.sm),
                          _DrawerItem(
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home_rounded,
                            title: 'navigation.home'.tr(),
                            onTap: () =>
                                _navigate(context, RouteNames.farmerHome),
                          ),
                          FeatureGuard(
                            featureKey: 'marketplace',
                            child: _DrawerItem(
                              icon: Icons.store_outlined,
                              activeIcon: Icons.store_rounded,
                              title: 'navigation.marketplace'.tr(),
                              onTap: () =>
                                  _navigate(context, RouteNames.marketplace),
                            ),
                          ),
                          FeatureGuard(
                            featureKey: 'orders',
                            child: _DrawerItem(
                              icon: Icons.shopping_bag_outlined,
                              activeIcon: Icons.shopping_bag_rounded,
                              title: 'navigation.orders'.tr(),
                              onTap: () => _navigate(context, RouteNames.orders),
                            ),
                          ),
                          FeatureGuard(
                            featureKey: 'myCrops',
                            child: _DrawerItem(
                              icon: Icons.agriculture_outlined,
                              activeIcon: Icons.agriculture_rounded,
                              title: 'home.quick_actions.my_crops'.tr(),
                              onTap: () => _navigate(context, RouteNames.myCrops),
                            ),
                          ),
                          FeatureGuard(
                            featureKey: 'ai',
                            fallbackMode: FeatureGuardMode.disable,
                            child: _DrawerItem(
                              icon: Icons.smart_toy_outlined,
                              activeIcon: Icons.smart_toy_rounded,
                              title: 'navigation.ai'.tr(),
                              onTap: () => _navigate(
                                context,
                                RouteNames.aiChat,
                                isPush: true,
                              ),
                              isAIPowered: true,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          _SectionLabel(label: 'navigation.explore'.tr()),
                          const SizedBox(height: AppSpacing.sm),
                          FeatureGuard(
                            featureKey: 'news',
                            fallbackMode: FeatureGuardMode.disable,
                            child: _DrawerItem(
                              icon: Icons.article_outlined,
                              activeIcon: Icons.article_rounded,
                              title: 'navigation.news'.tr(),
                              onTap: () =>
                                  _navigate(context, RouteNames.news, isPush: true),
                            ),
                          ),
                          _DrawerItem(
                            icon: Icons.help_outline_rounded,
                            activeIcon: Icons.help_rounded,
                            title: 'navigation.help'.tr(),
                            onTap: () =>
                                _navigate(context, RouteNames.help, isPush: true),
                          ),
                          FeatureGuard(
                            featureKey: 'marketRates',
                            child: _DrawerItem(
                              icon: Icons.analytics_outlined,
                              activeIcon: Icons.analytics_rounded,
                              title: 'market_rates.title'.tr(),
                              onTap: () => _navigate(
                                context,
                                RouteNames.marketRates,
                                isPush: true,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          _SectionLabel(label: 'navigation.settings'.tr()),
                          const SizedBox(height: AppSpacing.sm),
                          _DrawerItem(
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings_rounded,
                            title: 'settings.title'.tr(),
                            onTap: () => _navigate(
                              context,
                              RouteNames.settings,
                              isPush: true,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // Bottom Actions
                _bottomActions(context, ref, theme),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(
      begin: -1,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _header(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.eco_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "FarmZy",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: GlassContainer(
              borderRadius: 99,
              padding: const EdgeInsets.all(8),
              opacity: 0.1,
              blur: 0.0,
              child: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActions(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [_LogoutButton(onTap: () => _handleLogout(context, ref))],
      ),
    );
  }

  void _navigate(BuildContext context, String route, {bool isPush = false}) {
    Navigator.pop(context); // Close drawer
    if (isPush) {
      context.push(route);
    } else {
      context.go(route);
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      AppSnackBar.showSuccess(context, "Logout successful");
      context.go(RouteNames.login);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String title;
  final VoidCallback onTap;
  final bool isAIPowered;

  const _DrawerItem({
    required this.icon,
    this.activeIcon,
    required this.title,
    required this.onTap,
    this.isAIPowered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              if (isAIPowered)
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFFA855F7),
                      Color(0xFFEC4899),
                    ],
                  ).createShader(bounds),
                  child: Icon(icon, color: Colors.white, size: 24),
                )
              else
                Icon(
                  icon,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  size: 24,
                ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isAIPowered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: 16,
        opacity: 0.05,
        blur: 0.0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: GlassContainer(
        borderRadius: AppRadius.card,
        opacity: 0.05,
        blur: 0.0,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              "Logout",
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

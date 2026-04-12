import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const List<_DrawerItemData> _items = [
    _DrawerItemData(Icons.article_outlined, "News"),
    _DrawerItemData(Icons.language_outlined, "Change Language"),
    _DrawerItemData(Icons.agriculture_outlined, "See My Crops"),
    _DrawerItemData(Icons.add_circle_outline, "Add New Crop"),
    _DrawerItemData(Icons.account_balance_wallet_outlined, "Payment"),
    _DrawerItemData(Icons.receipt_long_outlined, "Transaction History"),
    _DrawerItemData(Icons.smart_toy_outlined, "FarmZy AI"),
    _DrawerItemData(Icons.help_outline, "Help"),
    _DrawerItemData(Icons.settings_outlined, "Settings"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "FarmZy",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colors.primary),

            /// MENU
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _DrawerItem(icon: item.icon, title: item.title);
                },
              ),
            ),

            /// LOGOUT (SAFE BOTTOM POSITION)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Material(
                  color: colors.error.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authControllerProvider.notifier).logout();

                      if (!context.mounted) return;
                      AppSnackBar.showSuccess(context, "Logged out successfully.");
                      context.go(RouteNames.login);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: colors.error),
                          const SizedBox(width: 16),
                          Text(
                            "Logout",
                            style: TextStyle(
                              color: colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItemData {
  final IconData icon;
  final String title;

  const _DrawerItemData(this.icon, this.title);
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DrawerItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: colors.primary.withValues(alpha: 0.15),
          highlightColor: colors.primary.withValues(alpha: 0.08),
          onTap: () {
            Navigator.pop(context);

            if (title == "See My Crops" || title == "Add New Crop") {
              context.go(RouteNames.myCrops);
              return;
            }

            if (title == "Payment") {
              context.go(RouteNames.orders);
              return;
            }

            if (title == "Settings") {
              context.go(RouteNames.profile);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

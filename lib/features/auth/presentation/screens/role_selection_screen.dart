import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) async {
    ref.read(selectedRoleProvider.notifier).state = role;
    await ref.read(secureStorageServiceProvider).savePendingRole(role);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedRole = ref.watch(selectedRoleProvider) ?? UserRole.farmer;

    return AuthPageScaffold(
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            text: 'common.continue'.tr(),
            onPressed: () {
              final route = switch (selectedRole) {
                UserRole.farmer || UserRole.admin || UserRole.owner => RouteNames.farmerRegister,
                UserRole.deliveryPartner => RouteNames.deliveryRegister,
              };
              context.go(route);
            },
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: AppSpacing.md),

          TextButton(
            onPressed: () => context.go(RouteNames.login),
            child: Text(
              'auth.login.already_account'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.primary,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              /// HEADER
              Text(
                'role.title'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontSize: 32,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'role.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 48),

              /// ROLE OPTIONS
              _RoleCard(
                title: 'role.farmer'.tr(),
                subtitle: 'role.farmer_desc'.tr(),
                icon: Icons.agriculture_rounded,
                isSelected: selectedRole == UserRole.farmer,
                accent: colors.primary,
                onTap: () => _selectRole(context, ref, UserRole.farmer),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.lg),

              _RoleCard(
                title: 'role.delivery'.tr(),
                subtitle: 'role.delivery_desc'.tr(),
                icon: Icons.local_shipping_rounded,
                isSelected: selectedRole == UserRole.deliveryPartner,
                accent: colors.secondary,
                onTap: () => _selectRole(context, ref, UserRole.deliveryPartner),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 25,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: AuthGlassCard(
          padding: EdgeInsets.zero,
          opacity: isSelected ? 0.12 : 0.05,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 32),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isSelected ? accent : theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: accent, size: 28)
                    .animate()
                    .scale(duration: 300.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

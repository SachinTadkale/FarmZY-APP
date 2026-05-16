import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);

    return AuthPageScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO/ICON
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: 32,
                  opacity: 0.1,
                  blur: 20,
                  child: Icon(
                    Icons.pending_actions_rounded,
                    size: 64,
                    color: colors.primary,
                  ),
                ).animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shimmer(delay: 1.seconds, duration: 1.5.seconds),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'v_pending.title'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    fontSize: 32,
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'v_pending.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: AppSpacing.xxl),

                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.card,
                  opacity: 0.05,
                  blur: 30,
                  child: Column(
                    children: [
                      AppButton(
                        text: 'v_pending.refresh'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: () => ref.read(authControllerProvider.notifier).refreshSession(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        text: 'v_pending.logout'.tr(),
                        variant: AppButtonVariant.outline,
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) context.go(RouteNames.roleSelection);
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

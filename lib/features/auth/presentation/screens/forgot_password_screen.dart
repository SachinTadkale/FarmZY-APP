import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:farmzy/shared/widgets/app_text_field.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_emailController.text.trim().isEmpty) {
      AppSnackBar.showError(context, 'auth.errors.email_required'.tr());
      return;
    }

    ref.read(authControllerProvider.notifier).forgotPassword(
      _emailController.text.trim(),
      role: ref.read(selectedRoleProvider) ?? UserRole.farmer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false && next.error == null) {
        AppSnackBar.showSuccess(context, 'auth.forgot_password.success_message'.tr());
        context.go(RouteNames.otpVerification, extra: {'email': _emailController.text.trim()});
      }
      if (next.error != null) AppSnackBar.showError(context, next.error!);
    });

    return AuthPageScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),

            /// LOGO/ICON
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: 32,
              opacity: 0.1,
              blur: 20,
              child: Icon(
                Icons.lock_reset_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'auth.forgot_password.title'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontSize: 32,
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'auth.forgot_password.subtitle'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.xxl),

            /// INPUT CARD
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.card,
              opacity: 0.05,
              blur: 30,
              child: Column(
                children: [
                  AppTextField(
                    controller: _emailController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    label: 'auth.forgot_password.email_label'.tr(),
                    prefixIcon: Icons.email_rounded,
                    onSubmitted: (_) => _handleSubmit(),
                    hint: "name@example.com",
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: 'auth.forgot_password.send_otp'.tr(),
                    isLoading: authState.isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xl),

            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'auth.forgot_password.back_to_login'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_passwordController.text.trim().isEmpty) {
      AppSnackBar.showError(context, 'auth.reset_password.errors.new_password_required'.tr());
      return;
    }
    if (_confirmController.text.trim().isEmpty) {
      AppSnackBar.showError(context, 'auth.reset_password.errors.confirm_password_required'.tr());
      return;
    }
    if (_passwordController.text.trim() != _confirmController.text.trim()) {
      AppSnackBar.showError(context, 'auth.reset_password.errors.password_mismatch'.tr());
      return;
    }

    ref.read(authControllerProvider.notifier).resetPassword(
          email: widget.email,
          otp: widget.otp,
          newPassword: _passwordController.text.trim(),
          confirmPassword: _confirmController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false && next.error == null) {
        AppSnackBar.showSuccess(context, 'auth.reset_password.success_message'.tr());
        context.go(RouteNames.login);
      }
      if (next.error != null) AppSnackBar.showError(context, next.error!);
    });

    return AuthPageScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),

            /// ICON
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: 32,
              opacity: 0.1,
              blur: 20,
              child: Icon(
                Icons.security_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'auth.reset_password.title'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontSize: 32,
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.sm),

            Text(
              widget.email,
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
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    nextFocusNode: _confirmFocus,
                    isPassword: true,
                    label: 'auth.reset_password.new_password_label'.tr(),
                    prefixIcon: Icons.lock_rounded,
                    hint: "Enter new password",
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _confirmController,
                    focusNode: _confirmFocus,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    label: 'auth.reset_password.confirm_password_label'.tr(),
                    prefixIcon: Icons.lock_clock_rounded,
                    onSubmitted: (_) => _handleSubmit(),
                    hint: "Confirm new password",
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: 'auth.reset_password.reset_button'.tr(),
                    isLoading: authState.isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

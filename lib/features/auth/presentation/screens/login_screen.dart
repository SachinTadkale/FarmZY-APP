import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode otpFocus = FocusNode();

  bool isOtpMode = false;
  bool _otpRequested = false;
  int _otpSecondsRemaining = 0;
  Timer? _otpTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    otpFocus.dispose();
    super.dispose();
  }

  void _handleAuthStateChange(
    BuildContext context,
    AuthState? previous,
    AuthState next,
  ) {
    if (next.error != null) {
      AppSnackBar.showError(context, next.error!);
    }

    if (next.isLoggedIn) {
      final nextRoute = next.requiresOnboarding
          ? RouteNames.onboarding
          : next.requiresVerification
          ? RouteNames.verificationPending
          : RouteNames.homeForRole(next.role);

      context.go(nextRoute);
    }
  }

  void _startOtpCountdown() {
    _otpTimer?.cancel();
    setState(() => _otpSecondsRemaining = 30);

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _otpSecondsRemaining = 0);
      } else {
        setState(() => _otpSecondsRemaining--);
      }
    });
  }

  String _otpCountdownLabel() =>
      '00:${_otpSecondsRemaining.toString().padLeft(2, '0')}';

  void _showMessage(String key) {
    AppSnackBar.showError(context, key.tr());
  }

  void _submitPasswordLogin() {
    if (emailController.text.isEmpty)
      return _showMessage('auth.errors.email_required');
    if (passwordController.text.isEmpty)
      return _showMessage('auth.errors.password_required');

    ref
        .read(authControllerProvider.notifier)
        .login(emailController.text.trim(), passwordController.text.trim());
  }

  void _requestOtp() {
    if (emailController.text.isEmpty)
      return _showMessage('auth.errors.email_required');

    ref
        .read(authControllerProvider.notifier)
        .requestOtp(emailController.text.trim());

    setState(() => _otpRequested = true);
    _startOtpCountdown();
  }

  void _submitOtpLogin() {
    if (emailController.text.isEmpty)
      return _showMessage('auth.errors.email_required');
    if (!_otpRequested) return _showMessage('auth.errors.otp_send_first');
    if (otpController.text.length < _otpLength) 
      return _showMessage('auth.errors.otp_required');

    ref
        .read(authControllerProvider.notifier)
        .loginWithOtp(emailController.text.trim(), otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => _handleAuthStateChange(context, previous, next),
    );

    return AuthPageScaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),

                /// BRANDING HEADER
                AuthGlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  opacity: 0.1,
                  blur: 20,
                  borderRadius: 20,
                  child: Icon(
                    Icons.agriculture_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'auth.login.title'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -1.5,
                    fontSize: 32,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'auth.login.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: AppSpacing.xl),

                /// MAIN FORM CARD
                AuthGlassCard(
                  showBorder: true,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  child: Column(
                    children: [
                      /// SEGMENTED TOGGLE
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildTab(
                              context,
                              'auth.login.password'.tr(),
                              !isOtpMode,
                              () => setState(() => isOtpMode = false),
                            ),
                            _buildTab(
                              context,
                              'auth.login.otp'.tr(),
                              isOtpMode,
                              () => setState(() => isOtpMode = true),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      AuthTextField(
                        controller: emailController,
                        focusNode: emailFocus,
                        nextFocusNode: isOtpMode ? null : passwordFocus,
                        label: 'auth.login.email'.tr(),
                        prefixIcon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        hint: "yourname@example.com",
                      ),

                      const SizedBox(height: AppSpacing.md),

                      if (!isOtpMode) ...[
                        AuthTextField(
                          controller: passwordController,
                          focusNode: passwordFocus,
                          label: 'auth.login.password_label'.tr(),
                          isPassword: true,
                          prefixIcon: Icons.lock_rounded,
                          hint: "••••••••",
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitPasswordLogin(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () =>
                                context.push(RouteNames.forgotPassword),
                            child: Text(
                              'auth.login.forgot_password'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.1,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (isOtpMode) ...[
                        AuthTextField(
                          controller: otpController,
                          focusNode: otpFocus,
                          label: 'OTP Code',
                          prefixIcon: Icons.pin_rounded,
                          keyboardType: TextInputType.number,
                          hint: "Enter 6-digit OTP",
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitOtpLogin(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: Text(
                            _otpRequested
                                ? "Resend in ${_otpCountdownLabel()}"
                                : 'auth.login.otp_hint'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isOtpMode &&
                            _otpRequested &&
                            _otpSecondsRemaining == 0)
                          TextButton(
                            onPressed: _requestOtp,
                            child: Text(
                              'auth.login.resend_otp'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],

                      const SizedBox(height: 24),

                      AppButton(
                        text: isOtpMode
                            ? (_otpRequested
                                  ? 'auth.login.verify_otp'.tr()
                                  : 'auth.login.send_otp'.tr())
                            : 'auth.login.login_button'.tr(),
                        isLoading: authState.isLoading,
                        onPressed: isOtpMode
                            ? (_otpRequested ? _submitOtpLogin : _requestOtp)
                            : _submitPasswordLogin,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auth.login.no_account'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.roleSelection),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'auth.login.create_account'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: isActive
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

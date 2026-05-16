import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get otpCode => _controllers.map((c) => c.text).join();
  bool get isOtpComplete => otpCode.length == _otpLength;

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < pasted.length) _controllers[i].text = pasted[i];
      }
      FocusScope.of(context).unfocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {});
  }

  void _onKeyPress(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
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
                Icons.verified_user_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'auth.otp.title'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontSize: 32,
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'auth.otp.subtitle'.tr(args: [widget.email]),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.xxl),

            /// OTP CELLS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_otpLength, (index) {
                return Focus(
                  onKeyEvent: (_, event) {
                    _onKeyPress(event, index);
                    return KeyEventResult.ignored;
                  },
                  child: SizedBox(
                    width: 52,
                    height: 64,
                    child: GlassContainer(
                      borderRadius: 16,
                      opacity: 0.08,
                      blur: 10,
                      padding: EdgeInsets.zero,
                      border: Border.all(
                        color: _focusNodes[index].hasFocus 
                          ? theme.colorScheme.primary 
                          : Colors.white.withValues(alpha: 0.1),
                        width: 2,
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (200 + (index * 50)).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
              }),
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              text: 'auth.otp.verify_button'.tr(),
              onPressed: isOtpComplete
                  ? () {
                      context.go(
                        RouteNames.resetPassword,
                        extra: {'email': widget.email, 'otp': otpCode},
                      );
                    }
                  : null,
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: AppSpacing.lg),

            TextButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).forgotPassword(
                            widget.email,
                            role: ref.read(selectedRoleProvider) ?? UserRole.farmer,
                          );
                    },
              child: Text(
                'auth.otp.resend'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

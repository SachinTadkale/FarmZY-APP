import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Merge OTP digits
  String get otpCode =>
      _controllers.map((c) => c.text).join();

  bool get isOtpComplete => otpCode.length == _otpLength;

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < pasted.length) {
          _controllers[i].text = pasted[i];
        }
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
    final primary = theme.colorScheme.primary;
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (action) {
          if (action == AuthAction.passwordResetOtpSent) {
            AppSnackBar.showSuccess(context, 'OTP sent to your email.');
          }
        },
        error: (error, _) {
          AppSnackBar.showError(
            context,
            error.toString().replaceFirst('Exception: ', ''),
          );
        },
      );
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Text(
                      "Verify Your Email",
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Enter the 6-digit verification code sent to ${widget.email}.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// OTP BOXES
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: List.generate(_otpLength, (index) {
                        return Focus(
                          onKeyEvent: (_, event) {
                            _onKeyPress(event, index);
                            return KeyEventResult.ignored;
                          },
                          child: SizedBox(
                            width: 48,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType:
                                  TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor:
                                    theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                              onChanged: (value) =>
                                  _onOtpChanged(value, index),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 40),

                    /// Verify Button
                    GestureDetector(
                      onTapDown: (_) =>
                          setState(() => _isPressed = true),
                      onTapUp: (_) =>
                          setState(() => _isPressed = false),
                      onTapCancel: () =>
                          setState(() => _isPressed = false),
                      child: AnimatedScale(
                        scale: _isPressed ? 0.96 : 1,
                        duration:
                            const Duration(milliseconds: 120),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isOtpComplete
                                ? () {
                                    context.go(
                                      RouteNames.resetPassword,
                                      extra: {
                                        'email': widget.email,
                                        'otp': otpCode,
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child:
                                const Text("Verify & Continue"),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .forgotPassword(widget.email);
                            },
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/auth_provider.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  bool isemailFocused = false;
  bool isPasswordFocused = false;
  bool isPressed = false;
  bool obscurePassword = true;
  bool isOtpMode = false;
  bool _otpRequested = false;
  int _otpSecondsRemaining = 0;
  Timer? _otpTimer;

  String get _otpCode => _otpControllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otpCode.length == _otpLength;
  bool get _canResendOtp => _otpSecondsRemaining == 0;

  @override
  void initState() {
    super.initState();

    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(_otpLength, (_) => FocusNode());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    emailFocus.addListener(() {
      setState(() => isemailFocused = emailFocus.hasFocus);
    });

    passwordFocus.addListener(() {
      setState(() => isPasswordFocused = passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleAuthStateChange(
    BuildContext context,
    AsyncValue<AuthAction?>? previous,
    AsyncValue<AuthAction?> next,
  ) {
    next.whenOrNull(
      data: (action) {
        if (action == AuthAction.otpSent) {
          setState(() {
            _otpRequested = true;
          });
          _clearOtpFields();
          _startOtpCountdown();
          if (_otpFocusNodes.isNotEmpty) {
            _otpFocusNodes.first.requestFocus();
          }
          AppSnackBar.showSuccess(context, 'OTP sent to your email.');
        } else if (action == AuthAction.loggedIn) {
          ref.read(authProvider.notifier).state = true;
          context.go(RouteNames.home);
        }
      },
      error: (error, _) {
        AppSnackBar.showError(context, _formatError(error));
      },
    );
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
  }

  void _startOtpCountdown() {
    _otpTimer?.cancel();
    setState(() {
      _otpSecondsRemaining = 30;
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_otpSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _otpSecondsRemaining = 0;
        });
        return;
      }

      setState(() {
        _otpSecondsRemaining -= 1;
      });
    });
  }

  String _otpCountdownLabel() {
    final seconds = _otpSecondsRemaining.toString().padLeft(2, '0');
    return '00:$seconds sec';
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        _otpControllers[i].text = i < pasted.length ? pasted[i] : '';
      }
      if (pasted.length >= _otpLength) {
        FocusScope.of(context).unfocus();
      } else if (pasted.isNotEmpty) {
        final nextIndex = pasted.length >= _otpLength
            ? _otpLength - 1
            : pasted.length;
        _otpFocusNodes[nextIndex].requestFocus();
      }
      setState(() {});
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }

    setState(() {});
  }

  void _onOtpKeyPress(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpControllers[index].text.isEmpty &&
        index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  void _switchLoginMode(bool useOtp) {
    setState(() {
      isOtpMode = useOtp;
      isPressed = false;
      if (!useOtp) {
        _clearOtpFields();
      }
    });
  }

  void _submitPasswordLogin() {
    if (emailController.text.trim().isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .login(emailController.text.trim(), passwordController.text.trim());
  }

  void _requestOtp() {
    if (emailController.text.trim().isEmpty) {
      _showMessage('Please enter your email to receive OTP.');
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .requestOtp(emailController.text.trim());
  }

  void _submitOtpLogin() {
    if (emailController.text.trim().isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (!_otpRequested) {
      _showMessage('Please send OTP first.');
      return;
    }

    if (!_isOtpComplete) {
      _showMessage('Please enter the 6-digit OTP.');
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .loginWithOtp(emailController.text.trim(), _otpCode);
  }

  void _showMessage(String message) {
    AppSnackBar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;
    final surface = theme.colorScheme.surface;
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      _handleAuthStateChange(context, previous, next);
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          color: background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/FarmZY_Logo.png',
                            height: 35,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      ClipOval(
                        child: Image.asset(
                          'assets/images/farmer.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Sign In', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primary),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchLoginMode(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isOtpMode
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomLeft: Radius.circular(14),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Login with Password',
                                    style: TextStyle(
                                      color: !isOtpMode
                                          ? Colors.white
                                          : primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchLoginMode(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOtpMode
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(14),
                                      bottomRight: Radius.circular(14),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Login with OTP',
                                    style: TextStyle(
                                      color: isOtpMode ? Colors.white : primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildAnimatedField(
                        isemailFocused,
                        primary,
                        TextFormField(
                          controller: emailController,
                          focusNode: emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: isOtpMode
                              ? TextInputAction.done
                              : TextInputAction.next,
                          onFieldSubmitted: (_) {
                            if (!isOtpMode) {
                              FocusScope.of(
                                context,
                              ).requestFocus(passwordFocus);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email, color: primary),
                            filled: true,
                            fillColor: surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isOtpMode) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: authState.isLoading || !_canResendOtp
                                ? null
                                : _requestOtp,
                            icon: const Icon(Icons.sms_outlined),
                            label: Text(
                              _otpRequested ? 'Re-Send OTP' : 'Send OTP',
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildOtpBoxes(theme),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _otpRequested
                                  ? (_canResendOtp
                                        ? 'You can request a new OTP now.'
                                        : _otpCountdownLabel())
                                  : 'Tap Send OTP to receive a 6-digit code.',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (_otpRequested)
                              Text(
                                'Check your email inbox',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (!isOtpMode)
                        _buildAnimatedField(
                          isPasswordFocused,
                          primary,
                          TextFormField(
                            controller: passwordController,
                            focusNode: passwordFocus,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      if (!isOtpMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push(RouteNames.forgotPassword);
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTapDown: (_) => setState(() => isPressed = true),
                        onTapUp: (_) => setState(() => isPressed = false),
                        onTapCancel: () => setState(() => isPressed = false),
                        child: AnimatedScale(
                          scale: isPressed ? 0.96 : 1,
                          duration: const Duration(milliseconds: 120),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      if (isOtpMode) {
                                        _submitOtpLogin();
                                      } else {
                                        _submitPasswordLogin();
                                      }
                                    },
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isOtpMode
                                          ? 'Verify OTP & Login'
                                          : 'Log In',
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't Have an Account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(RouteNames.register);
                            },
                            child: Text(
                              'Create Account',
                              style: TextStyle(color: primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField(bool isFocused, Color primary, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }

  Widget _buildOtpBoxes(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return Focus(
          onKeyEvent: (_, event) {
            _onOtpKeyPress(event, index);
            return KeyEventResult.ignored;
          },
          child: SizedBox(
            width: 48,
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) => _onOtpChanged(value, index),
            ),
          ),
        );
      }),
    );
  }
}

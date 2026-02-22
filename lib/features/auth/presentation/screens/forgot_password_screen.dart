import 'package:farmzy/core/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _focusNode = FocusNode();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPressed = false;
  bool _isFocused = false;

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

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mobileController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    /// Title (Updated for better UX)
                    Text(
                      "Recover Your Account",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Clear Description
                    Text(
                      "Enter your registered mobile number to receive a verification OTP.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 36),

                    /// Phone Field with Glow
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isFocused
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.20),
                                  blurRadius: 12,
                                ),
                              ]
                            : [],
                      ),
                      child: TextField(
                        controller: _mobileController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: "Registered Mobile Number",
                          prefixIcon:
                              Icon(Icons.phone, color: primary),
                          filled: true,
                          fillColor: surface,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    /// Send OTP Button
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
                            onPressed: () {
                              context.push(
                                  RouteNames.otpVerification);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            child:
                                const Text("Send Verification OTP"),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Back to Login
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        "Back to Sign In",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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
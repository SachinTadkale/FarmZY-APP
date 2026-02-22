import 'package:farmzy/core/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FocusNode phoneFocus = FocusNode();
  final FocusNode otpFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool isPhoneFocused = false;
  bool isOtpFocused = false;
  bool isPasswordFocused = false;

  bool isPressed = false;
  bool obscurePassword = true;

  /// true = OTP mode, false = Password mode
  bool isOtpMode = true;

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

    phoneFocus.addListener(() {
      setState(() => isPhoneFocused = phoneFocus.hasFocus);
    });

    otpFocus.addListener(() {
      setState(() => isOtpFocused = otpFocus.hasFocus);
    });

    passwordFocus.addListener(() {
      setState(() => isPasswordFocused = passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    phoneFocus.dispose();
    otpFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;
    final surface = theme.colorScheme.surface;

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

                      /// Logo
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/FarmZY_Logo.png',
                            height: 35,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// Avatar
                      ClipOval(
                        child: Image.asset(
                          "assets/images/farmer.png",
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text("Sign In",
                          style: theme.textTheme.titleLarge),

                      const SizedBox(height: 20),

                      /// Segmented Toggle
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primary),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isOtpMode = false;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: !isOtpMode
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius:
                                        const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomLeft: Radius.circular(14),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Login with Password",
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
                                onTap: () {
                                  setState(() {
                                    isOtpMode = true;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isOtpMode
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius:
                                        const BorderRadius.only(
                                      topRight: Radius.circular(14),
                                      bottomRight: Radius.circular(14),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Login with OTP",
                                    style: TextStyle(
                                      color: isOtpMode
                                          ? Colors.white
                                          : primary,
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

                      /// Phone Field
                      _buildAnimatedField(
                        isPhoneFocused,
                        primary,
                        TextFormField(
                          focusNode: phoneFocus,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            if (isOtpMode) {
                              nextField(otpFocus);
                            } else {
                              nextField(passwordFocus);
                            }
                          },
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

                      const SizedBox(height: 20),

                      /// OTP FIELD
                      if (isOtpMode)
                        _buildAnimatedField(
                          isOtpFocused,
                          primary,
                          TextFormField(
                            focusNode: otpFocus,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: "OTP",
                              prefixIcon: Icon(
                                  Icons.sms_outlined,
                                  color: primary),
                              filled: true,
                              fillColor: surface,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                      /// PASSWORD FIELD
                      if (!isOtpMode)
                        _buildAnimatedField(
                          isPasswordFocused,
                          primary,
                          TextFormField(
                            focusNode: passwordFocus,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon:
                                  Icon(Icons.lock, color: primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                        !obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: surface,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                      // const SizedBox(height: 10),

                      /// Extra Actions
                      if (isOtpMode)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text("00:30 sec",
                                style: theme.textTheme.bodySmall),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Re-Send OTP",
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                      if (!isOtpMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push(RouteNames.forgotPassword);
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),

                      /// Login Button
                      GestureDetector(
                        onTapDown: (_) =>
                            setState(() => isPressed = true),
                        onTapUp: (_) =>
                            setState(() => isPressed = false),
                        onTapCancel: () =>
                            setState(() => isPressed = false),
                        child: AnimatedScale(
                          scale: isPressed ? 0.96 : 1,
                          duration:
                              const Duration(milliseconds: 120),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push(RouteNames.home);
                              },
                              child: const Text("Log In"),
                            ),
                          ),
                        ),
                      ),

                      // const SizedBox(height: 20),

                      /// Create Account
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
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
                              "Create Account",
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

  Widget _buildAnimatedField(
      bool isFocused, Color primary, Widget child) {
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
}
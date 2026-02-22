import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicDetailsStep extends ConsumerStatefulWidget {
  const BasicDetailsStep({super.key});

  @override
  ConsumerState<BasicDetailsStep> createState() =>
      _BasicDetailsStepState();
}

class _BasicDetailsStepState
    extends ConsumerState<BasicDetailsStep> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  bool isNameFocused = false;
  bool isPhoneFocused = false;
  bool isPasswordFocused = false;
  bool isConfirmPasswordFocused = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? selectedGender;

  /// 👇 Cleaner helper for moving focus
  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  @override
  void initState() {
    super.initState();

    nameFocus.addListener(() {
      setState(() => isNameFocused = nameFocus.hasFocus);
    });

    phoneFocus.addListener(() {
      setState(() => isPhoneFocused = phoneFocus.hasFocus);
    });

    passwordFocus.addListener(() {
      setState(() => isPasswordFocused = passwordFocus.hasFocus);
    });

    confirmPasswordFocus.addListener(() {
      setState(() =>
          isConfirmPasswordFocused = confirmPasswordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();

    super.dispose();
  }

  Widget buildAnimatedField({
    required bool isFocused,
    required Widget child,
    required Color primary,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.20),
                  blurRadius: 12,
                )
              ]
            : [],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Create Account",
            style: theme.textTheme.titleLarge),

        const SizedBox(height: 20),

        /// 🔹 Name
        buildAnimatedField(
          isFocused: isNameFocused,
          primary: primary,
          child: TextFormField(
            controller: nameController,
            focusNode: nameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(phoneFocus),
            decoration: InputDecoration(
              hintText: "Full Name (as per Aadhaar)",
              prefixIcon:
                  Icon(Icons.person, color: primary),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔹 Phone
        buildAnimatedField(
          isFocused: isPhoneFocused,
          primary: primary,
          child: TextFormField(
            controller: phoneController,
            focusNode: phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(emailFocus),
            decoration: InputDecoration(
              hintText: "Mobile Number",
              prefixIcon:
                  Icon(Icons.phone, color: primary),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔹 Gender Dropdown
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: InputDecoration(
            hintText: "Select Gender",
            prefixIcon:
                Icon(Icons.wc, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          items: const [
            DropdownMenuItem(
                value: "Male", child: Text("Male")),
            DropdownMenuItem(
                value: "Female", child: Text("Female")),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
            nextField(emailFocus);
          },
        ),

        const SizedBox(height: 20),

        /// 🔹 Email
        TextFormField(
          controller: emailController,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(passwordFocus),
          decoration: InputDecoration(
            hintText: "Email (Optional)",
            prefixIcon:
                Icon(Icons.email, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔹 Password
        buildAnimatedField(
          isFocused: isPasswordFocused,
          primary: primary,
          child: TextFormField(
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                nextField(confirmPasswordFocus),
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

        const SizedBox(height: 20),

        /// 🔹 Confirm Password
        buildAnimatedField(
          isFocused: isConfirmPasswordFocused,
          primary: primary,
          child: TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocus,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              confirmPasswordFocus.unfocus();
              // Optional: call submit function here
              // _submitForm();
            },
            decoration: InputDecoration(
              hintText: "Confirm Password",
              prefixIcon:
                  Icon(Icons.lock_outline, color: primary),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword =
                        !obscureConfirmPassword;
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
      ],
    );
  }
}
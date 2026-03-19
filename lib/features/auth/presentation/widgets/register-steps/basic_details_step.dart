import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicDetailsStep extends ConsumerStatefulWidget {
  const BasicDetailsStep({super.key});

  @override
  ConsumerState<BasicDetailsStep> createState() => _BasicDetailsStepState();
}

class _BasicDetailsStepState extends ConsumerState<BasicDetailsStep> {
  static const double _fieldRadius = 12;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$',
  );

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();
  final addressFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  bool isNameFocused = false;
  bool isPhoneFocused = false;
  bool isEmailFocused = false;
  bool isAddressFocused = false;
  bool isPasswordFocused = false;
  bool isConfirmPasswordFocused = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    final registerState = ref.read(registerProvider);
    nameController = TextEditingController(text: registerState.name);
    phoneController = TextEditingController(text: registerState.phone);
    emailController = TextEditingController(text: registerState.email);
    addressController = TextEditingController(text: registerState.address);
    passwordController = TextEditingController(text: registerState.password);
    confirmPasswordController = TextEditingController(
      text: registerState.confirmPassword,
    );
    selectedGender =
        registerState.gender.isEmpty ? null : registerState.gender.toUpperCase();

    nameFocus.addListener(() => setState(() => isNameFocused = nameFocus.hasFocus));
    phoneFocus.addListener(() => setState(() => isPhoneFocused = phoneFocus.hasFocus));
    emailFocus.addListener(() => setState(() => isEmailFocused = emailFocus.hasFocus));
    addressFocus.addListener(
      () => setState(() => isAddressFocused = addressFocus.hasFocus),
    );
    passwordFocus.addListener(
      () => setState(() => isPasswordFocused = passwordFocus.hasFocus),
    );
    confirmPasswordFocus.addListener(
      () => setState(
        () => isConfirmPasswordFocused = confirmPasswordFocus.hasFocus,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    addressFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _updateBasicState({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? password,
    String? confirmPassword,
    String? gender,
  }) {
    ref.read(registerProvider.notifier).updateBasicDetails(
          name: name,
          phone: phone,
          email: email,
          address: address,
          password: password,
          confirmPassword: confirmPassword,
          gender: gender,
        );
  }

  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  Widget buildAnimatedField({
    required bool isFocused,
    required Widget child,
    required Color primary,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_fieldRadius),
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

  @override
  Widget build(BuildContext context) {
    final showEmailError =
        !isEmailFocused &&
        emailController.text.trim().isNotEmpty &&
        !_emailRegex.hasMatch(emailController.text.trim());
    final showPhoneError =
        !isPhoneFocused &&
        phoneController.text.trim().isNotEmpty &&
        !_phoneRegex.hasMatch(phoneController.text.trim());
    final showPasswordError =
        !isPasswordFocused &&
        passwordController.text.isNotEmpty &&
        !_passwordRegex.hasMatch(passwordController.text.trim());
    final showConfirmPasswordError =
        !isConfirmPasswordFocused &&
        confirmPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.trim() != passwordController.text.trim();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAnimatedField(
          isFocused: isNameFocused,
          primary: primary,
          child: TextFormField(
            controller: nameController,
            focusNode: nameFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(phoneFocus),
            onChanged: (value) => _updateBasicState(name: value),
            decoration: InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person, color: primary),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildAnimatedField(
          isFocused: isEmailFocused,
          primary: primary,
          child: TextFormField(
            controller: emailController,
            focusNode: emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(addressFocus),
            onChanged: (value) {
              _updateBasicState(email: value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email, color: primary),
              errorText: showEmailError ? 'Enter a valid email address.' : null,
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildAnimatedField(
          isFocused: isPhoneFocused,
          primary: primary,
          child: TextFormField(
            controller: phoneController,
            focusNode: phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(emailFocus),
            onChanged: (value) {
              _updateBasicState(phone: value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone, color: primary),
              errorText:
                  showPhoneError ? 'Enter a valid 10-digit mobile number.' : null,
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                label: 'Male',
                icon: Icons.male_rounded,
                selected: selectedGender == 'MALE',
                onTap: () {
                  setState(() {
                    selectedGender = 'MALE';
                  });
                  _updateBasicState(gender: 'MALE');
                  nextField(addressFocus);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderCard(
                label: 'Female',
                icon: Icons.female_rounded,
                selected: selectedGender == 'FEMALE',
                onTap: () {
                  setState(() {
                    selectedGender = 'FEMALE';
                  });
                  _updateBasicState(gender: 'FEMALE');
                  nextField(addressFocus);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildAnimatedField(
          isFocused: isAddressFocused,
          primary: primary,
          child: TextFormField(
            controller: addressController,
            focusNode: addressFocus,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(passwordFocus),
            onChanged: (value) => _updateBasicState(address: value),
            decoration: InputDecoration(
              hintText: 'Address',
              prefixIcon: Icon(Icons.location_pin, color: primary),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildAnimatedField(
          isFocused: isPasswordFocused,
          primary: primary,
          child: TextFormField(
            controller: passwordController,
            focusNode: passwordFocus,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => nextField(confirmPasswordFocus),
            onChanged: (value) {
              _updateBasicState(password: value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock, color: primary),
              errorText: showPasswordError
                  ? 'Use 8+ chars with uppercase, lowercase, number and symbol.'
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildAnimatedField(
          isFocused: isConfirmPasswordFocused,
          primary: primary,
          child: TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocus,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => confirmPasswordFocus.unfocus(),
            onChanged: (value) {
              _updateBasicState(confirmPassword: value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline, color: primary),
              errorText: showConfirmPasswordError
                  ? 'Confirm password must match the password.'
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_fieldRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Password must contain uppercase, lowercase, number, special character, and be at least 8 characters long.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : primary.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

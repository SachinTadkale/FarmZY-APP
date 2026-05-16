import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_step_header.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_validateStep1()) {
        _pageController.nextPage(
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
        );
        setState(() => _currentStep = 1);
      }
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      _pageController.previousPage(
        duration: AppAnimations.normal,
        curve: Curves.easeOut,
      );
      setState(() => _currentStep = 0);
    } else {
      context.go(RouteNames.roleSelection);
    }
  }

  bool _validateStep1() {
    if (_nameController.text.trim().isEmpty) {
      AppSnackBar.showError(context, 'auth.register.errors.name_required'.tr());
      return false;
    }
    if (_emailController.text.trim().isEmpty ||
        !RegExp(
          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
        ).hasMatch(_emailController.text.trim())) {
      AppSnackBar.showError(context, 'auth.register.errors.email_invalid'.tr());
      return false;
    }
    if (_phoneController.text.trim().isEmpty ||
        !RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim())) {
      AppSnackBar.showError(context, 'auth.register.errors.phone_invalid'.tr());
      return false;
    }
    if (_selectedGender == null) {
      AppSnackBar.showError(
        context,
        'auth.register.errors.gender_required'.tr(),
      );
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty ||
        !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password)) {
      AppSnackBar.showError(context, 'auth.register.errors.password_weak'.tr());
      return false;
    }
    if (confirmPassword != password) {
      AppSnackBar.showError(
        context,
        'auth.register.errors.password_mismatch'.tr(),
      );
      return false;
    }
    return true;
  }

  void _handleRegister(UserRole role) async {
    if (!_validateStep2()) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          gender: _selectedGender!,
          password: _passwordController.text.trim(),
          role: role,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final role = ref.watch(selectedRoleProvider) ?? UserRole.farmer;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.error != null) AppSnackBar.showError(context, next.error!);
    });

    return AuthPageScaffold(
      bottomBar: Row(
        children: [
          if (_currentStep > 0 || true) ...[
            Expanded(
              flex: 1,
              child: AppButton(
                text: 'auth.register.back'.tr(),
                variant: AppButtonVariant.outline,
                icon: Icons.arrow_back_rounded,
                onPressed: _prevStep,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: AppButton(
              text: _currentStep == 1
                  ? 'auth.register.create_account'.tr()
                  : 'auth.register.next'.tr(),
              isLoading: auth.isLoading,
              icon: _currentStep == 1
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: () =>
                  _currentStep == 1 ? _handleRegister(role) : _nextStep(),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AuthStepHeader(
              currentStep: 1,
              totalSteps: 4,
              title: 'auth.register.title'.tr(),
              subtitle: 'auth.register.subtitle'.tr(),
            ),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(theme), _buildStep2(theme, role)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AuthGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTextField(
              controller: _nameController,
              focusNode: _nameFocus,
              nextFocusNode: _emailFocus,
              label: 'auth.register.full_name'.tr(),
              prefixIcon: Icons.person_rounded,
              hint: 'auth.register.full_name'.tr(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              nextFocusNode: _phoneFocus,
              keyboardType: TextInputType.emailAddress,
              label: 'auth.register.email'.tr(),
              prefixIcon: Icons.email_rounded,
              hint: "name@example.com",
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              nextFocusNode: _addressFocus,
              keyboardType: TextInputType.phone,
              label: 'auth.register.phone'.tr(),
              prefixIcon: Icons.phone_rounded,
              hint: "9876543210",
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _addressController,
              focusNode: _addressFocus,
              label: 'auth.register.address'.tr(),
              prefixIcon: Icons.location_on_rounded,
              hint: "Village, District, State",
              onSubmitted: (_) => _nextStep(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'auth.register.gender'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.0,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    _buildGenderItem(
                      'MALE',
                      'auth.register.male'.tr(),
                      Icons.male_rounded,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildGenderItem(
                      'FEMALE',
                      'auth.register.female'.tr(),
                      Icons.female_rounded,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(ThemeData theme, UserRole role) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AuthGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'auth.register.account_security'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AuthTextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              nextFocusNode: _confirmPasswordFocus,
              isPassword: true,
              label: 'auth.register.password'.tr(),
              prefixIcon: Icons.lock_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              isPassword: true,
              textInputAction: TextInputAction.done,
              label: 'auth.register.confirm_password'.tr(),
              prefixIcon: Icons.lock_rounded,
              onSubmitted: (_) => _handleRegister(role),
            ),
            const SizedBox(height: 32),
            Text(
              "By creating an account, you agree to our Terms of Service and Privacy Policy.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderItem(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

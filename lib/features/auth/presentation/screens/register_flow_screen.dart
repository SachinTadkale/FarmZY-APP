import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/bank_details_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/basic_details_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/farm_details_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/under_review_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/verification_step.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/register_flow_controller.dart';
import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFlowScreen extends ConsumerStatefulWidget {
  const RegisterFlowScreen({super.key});

  @override
  ConsumerState<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends ConsumerState<RegisterFlowScreen>
    with SingleTickerProviderStateMixin {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');
  static final RegExp _aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$',
  );

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const int totalSteps = 5;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ✅ FIXED: use step parameter only
  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 0:
        return const BasicDetailsStep();
      case 1:
        return const FarmDetailsStep();
      case 2:
        return const BankDetailsStep();
      case 3:
        return const VerificationStep();
      case 4:
        return const UnderReviewStep();
      default:
        return const BasicDetailsStep();
    }
  }

  bool _isCurrentStepValid(RegisterState state) {
    switch (state.currentStep) {
      case 0:
        return state.name.trim().isNotEmpty &&
            _emailRegex.hasMatch(state.email.trim()) &&
            _phoneRegex.hasMatch(state.phone.trim()) &&
            state.address.trim().isNotEmpty &&
            state.gender.trim().isNotEmpty &&
            _passwordRegex.hasMatch(state.password.trim()) &&
            state.confirmPassword.trim().isNotEmpty &&
            state.password.trim() == state.confirmPassword.trim();

      case 1:
        return state.stateName.trim().isNotEmpty &&
            state.district.trim().isNotEmpty &&
            state.village.trim().isNotEmpty &&
            RegExp(r'^\d{6}$').hasMatch(state.pincode.trim()) &&
            double.tryParse(state.landArea.trim()) != null;

      case 2:
        return state.accountHolder.trim().isNotEmpty &&
            state.accountNumber.trim().isNotEmpty &&
            state.confirmAccountNumber.trim().isNotEmpty &&
            state.bankName.trim().isNotEmpty &&
            state.ifsc.trim().isNotEmpty &&
            state.accountNumber.trim() == state.confirmAccountNumber.trim();

      case 3:
        final idNumber = state.idNumber.trim().toUpperCase();
        final isIdValid = state.idType == 'AADHAR'
            ? _aadhaarRegex.hasMatch(idNumber)
            : state.idType == 'PAN'
            ? _panRegex.hasMatch(idNumber)
            : false;

        return state.idType.trim().isNotEmpty &&
            isIdValid &&
            state.frontImage != null &&
            (state.idType != 'AADHAR' || state.backImage != null) &&
            state.agreeTerms;

      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);
    final submissionState = ref.watch(registerFlowControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    /// 🔥 CRITICAL FIX: Sync backend step → UI step
    if (state.currentStep != auth.registrationStep) {
      Future.microtask(() {
        ref.read(registerProvider.notifier).setStep(auth.registrationStep);
      });
    }

    final double progress = (state.currentStep + 1) / totalSteps;

    /// Error listener
    ref.listen(registerFlowControllerProvider, (previous, next) {
      next.whenOrNull(
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    Text("Step ${state.currentStep + 1} of $totalSteps"),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: theme.colorScheme.surface,
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _buildCurrentStep(state.currentStep),
                      ),
                    ),

                    /// Buttons
                    if (state.currentStep < 4)
                      Row(
                        children: [
                          if (state.currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: submissionState.isLoading
                                    ? null
                                    : notifier.previousStep,
                                child: const Text("Back"),
                              ),
                            ),

                          if (state.currentStep > 0) const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  submissionState.isLoading ||
                                      !_isCurrentStepValid(state)
                                  ? null
                                  : () {
                                      ref
                                          .read(
                                            registerFlowControllerProvider
                                                .notifier,
                                          )
                                          .submitCurrentStep();
                                    },
                              child: submissionState.isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      state.currentStep == 3
                                          ? "Submit"
                                          : "Next",
                                    ),
                            ),
                          ),
                        ],
                      ),

                    /// Final step
                    if (state.currentStep == 4)
                      ElevatedButton(
                        onPressed: () {
                          /// ✅ Mark onboarding complete
                          ref
                              .read(authControllerProvider.notifier)
                              .updateOnboardingCompleted();

                          context.go(RouteNames.home);
                        },
                        child: const Text("Go to Home"),
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

import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/bank_details_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/basic_details_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/farm_details_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/under_review_step.dart';
import 'package:farmzy/features/auth/presentation/widgets/register-steps/verification_step.dart';
import 'package:farmzy/features/auth/providers/register_provider.dart';
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
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isPressed = false;

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final double progress = (state.currentStep + 1) / totalSteps;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
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

                    const SizedBox(height: 25),

                    /// Step Text
                    Text(
                      "Step ${state.currentStep + 1} of $totalSteps",
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 10),

                    /// Rounded Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: primary.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(primary),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔥 ONLY STEP CONTENT SCROLLS
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: SizedBox(
                              key: ValueKey(state.currentStep),
                              child: _buildCurrentStep(state.currentStep),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    if (state.currentStep < 4)
                      Row(
                        children: [
                          if (state.currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: notifier.previousStep,
                                child: const Text("Back"),
                              ),
                            ),

                          if (state.currentStep > 0) const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: notifier.nextStep,
                              child: Text(
                                state.currentStep == 3 ? "Submit" : "Next",
                              ),
                            ),
                          ),
                        ],
                      ),

                    if (state.currentStep == 4)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(RouteNames.login);
                          },
                          child: const Text("Go to Log In"),
                        ),
                      ),

                    const SizedBox(height: 20),
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

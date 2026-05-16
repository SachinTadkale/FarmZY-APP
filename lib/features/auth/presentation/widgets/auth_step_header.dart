import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;

  const AuthStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            fontSize: 32,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),

        const SizedBox(height: AppSpacing.xs),

        Row(
          children: [
            Text(
              "Step $currentStep of $totalSteps",
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              "${(progress * 100).toInt()}%",
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: AppSpacing.sm),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ).animate().scaleX(begin: 0, duration: 600.ms, curve: Curves.easeOut),

        const SizedBox(height: AppSpacing.xs),

        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureUnavailableScreen extends StatelessWidget {
  final String featureName;
  final bool isComingSoon;

  const FeatureUnavailableScreen({
    super.key,
    required this.featureName,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.go(RouteNames.splash),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isComingSoon ? Colors.blue : Colors.orange).withOpacity(0.12),
                ),
                child: Icon(
                  isComingSoon ? Icons.rocket_launch_rounded : Icons.lock_clock_rounded,
                  color: isComingSoon ? Colors.blue : Colors.orange,
                  size: 48,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                isComingSoon
                    ? tr('feature_unavailable.coming_soon_title', args: [featureName])
                    : tr('feature_unavailable.disabled_title', args: [featureName]),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                isComingSoon
                    ? tr('feature_unavailable.coming_soon_subtitle')
                    : tr('feature_unavailable.disabled_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 48),
              
              // Back Button
              ElevatedButton(
                onPressed: () => context.go(RouteNames.splash),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(tr('common.back_to_home')),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

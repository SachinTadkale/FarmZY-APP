import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:farmzy/features/settings/providers/settings_controller.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final bool isOnboarding = !settings.hasSelectedLanguage;

    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English', 'label': 'E'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी', 'label': 'ह'},
      {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी', 'label': 'म'},
    ];

    return AuthPageScaffold(
      bottomBar: AppButton(
        text: 'common.continue'.tr(),
        onPressed: () async {
          if (isOnboarding) {
            await ref.read(settingsControllerProvider.notifier).completeLanguageSelection();
          }

          if (!context.mounted) return;

          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.roleSelection);
          }
        },
      ).animate().fadeIn(delay: 600.ms),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              
              /// HEADER
              Column(
                children: [
                  Text(
                    'language.title'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      fontSize: 36,
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'language.subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 56),

              /// GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.82,
                ),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = settings.languageCode == lang['code'];

                  return _LanguageCard(
                    name: lang['name']!,
                    nativeName: lang['native']!,
                    label: lang['label']!,
                    isSelected: isSelected,
                    onTap: () async {
                      await ref.read(settingsControllerProvider.notifier).updateLanguage(lang['code']!);
                      if (context.mounted) {
                        await context.setLocale(Locale(lang['code']!));
                      }
                    },
                  ).animate()
                   .fadeIn(delay: (200 + (index * 100)).ms)
                   .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
                },
              ),
              
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String name;
  final String nativeName;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.name,
    required this.nativeName,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    const radius = 32.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: AppAnimations.normal,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: isSelected ? [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: -12,
                offset: const Offset(0, 10),
              ),
            ] : [],
          ),
          child: AuthGlassCard(
            padding: EdgeInsets.zero,
            opacity: isSelected ? 0.15 : 0.06,
            blur: isSelected ? 50 : 30,
            borderRadius: radius,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: isSelected 
                    ? primary.withValues(alpha: 0.8) 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  width: isSelected ? 2.5 : 1.2,
                ),
                gradient: isSelected ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.15),
                    primary.withValues(alpha: 0.05),
                  ],
                ) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPremiumTypographicIcon(context, isSelected),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      fontSize: 19,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTypographicIcon(BuildContext context, bool isSelected) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected 
          ? primary.withValues(alpha: 0.2) 
          : theme.colorScheme.onSurface.withValues(alpha: 0.03),
        border: Border.all(
          color: isSelected ? primary.withValues(alpha: 0.5) : theme.colorScheme.onSurface.withValues(alpha: 0.08),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected 
              ? [primary, primary.withValues(alpha: 0.8)]
              : [
                  theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  theme.colorScheme.onSurface.withValues(alpha: 0.05),
                ],
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: primary.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}

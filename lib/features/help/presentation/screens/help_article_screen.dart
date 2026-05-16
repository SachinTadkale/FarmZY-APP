import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/help/data/models/help_models.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HelpArticleScreen extends StatelessWidget {
  final HelpArticle article;

  const HelpArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('help.article_details'.tr()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  color: colors.primary,
                  opacity: 0.1,
                  child: Icon(_getIconData(article.icon), color: colors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    article.titleKey.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xl),

            // Content
            ...article.contentKeys.map((key) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                key.tr(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            )),

            if (article.stepKeys.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'help.step_by_step'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              ...article.stepKeys.asMap().entries.map((entry) => _buildStep(entry.key + 1, entry.value.tr(), theme)),
            ],

            if (article.faqKeys.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'help.faq'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.md),
              ...article.faqKeys.map((key) => _buildFAQ(key.tr(), theme)),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildFAQ(String text, ThemeData theme) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      borderRadius: AppRadius.md,
      opacity: 0.05,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(text, style: theme.textTheme.bodyMedium),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'rocket_launch_rounded': return Icons.rocket_launch_rounded;
      case 'person_add_rounded': return Icons.person_add_rounded;
      case 'add_business_rounded': return Icons.add_business_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

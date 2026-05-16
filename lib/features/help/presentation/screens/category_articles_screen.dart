import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/help/data/models/help_models.dart';
import 'package:farmzy/features/help/presentation/providers/help_provider.dart';
import 'package:farmzy/features/help/presentation/screens/help_article_screen.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoryArticlesScreen extends ConsumerWidget {
  final HelpCategory category;

  const CategoryArticlesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final articles = ref.watch(helpArticlesProvider).where((e) => e.categoryId == category.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.titleKey.tr()),
      ),
      body: articles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('help.no_articles'.tr(), style: theme.textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final article = articles[index];
                return GlassContainer(
                  borderRadius: AppRadius.card,
                  opacity: 0.05,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(_getIconData(article.icon), color: theme.colorScheme.primary),
                    title: Text(
                      article.titleKey.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      article.descriptionKey.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HelpArticleScreen(article: article)),
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
              },
            ),
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

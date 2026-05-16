import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/help/data/models/help_models.dart';
import 'package:farmzy/features/help/presentation/providers/help_provider.dart';
import 'package:farmzy/features/help/presentation/screens/category_articles_screen.dart';
import 'package:farmzy/features/help/presentation/screens/help_article_screen.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/premium_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(helpSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearching = ref.watch(helpSearchQueryProvider).isNotEmpty;

    return AppScaffold(
      appBar: AppBar(
        title: Text('navigation.help'.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          PremiumSearchBar(
            controller: _searchController,
            hintText: 'help.search_hint'.tr(),
            onChanged: (val) => ref.read(helpSearchQueryProvider.notifier).state = val,
            suffix: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(helpSearchQueryProvider.notifier).state = '';
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isSearching)
            _SearchResults()
          else ...[
            Text(
              'help.categories'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            _CategoriesGrid(),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'help.faq'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            _FAQItem(
              question: "How do I list a new crop?",
              answer: "Go to Marketplace > Add Listing and select one of your verified crops.",
            ),
            _FAQItem(
              question: "When will I receive my payment?",
              answer: "Payments are typically processed within 24 hours of delivery confirmation.",
            ),
            _FAQItem(
              question: "How does the AI assistant help?",
              answer: "FarmZY AI can provide market predictions, crop disease diagnosis, and weather advice.",
            ),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final results = ref.watch(filteredArticlesProvider);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('common.no_results'.tr(), style: theme.textTheme.bodyLarge),
              Text('common.try_again'.tr(), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Column(
      children: results.map((article) {
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          borderRadius: AppRadius.card,
          opacity: 0.05,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(Icons.article_outlined, color: theme.colorScheme.primary),
            title: Text(
              article.titleKey.tr(),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              article.descriptionKey.tr(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HelpArticleScreen(article: article)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategoriesGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(helpCategoriesProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _HelpCategoryCard(category: category);
      },
    );
  }
}

class _HelpCategoryCard extends StatelessWidget {
  final HelpCategory category;

  const _HelpCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(int.parse(category.color));

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryArticlesScreen(category: category)),
      ),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: GlassContainer(
        borderRadius: AppRadius.card,
        opacity: 0.05,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconData(category.icon), color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              category.titleKey.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'rocket_launch_rounded': return Icons.rocket_launch_rounded;
      case 'storefront_rounded': return Icons.storefront_rounded;
      case 'shopping_cart_rounded': return Icons.shopping_cart_rounded;
      case 'payments_rounded': return Icons.payments_rounded;
      case 'local_shipping_rounded': return Icons.local_shipping_rounded;
      case 'account_circle_rounded': return Icons.account_circle_rounded;
      case 'smart_toy_rounded': return Icons.smart_toy_rounded;
      case 'quiz_rounded': return Icons.quiz_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        borderRadius: AppRadius.card,
        opacity: 0.04,
        padding: const EdgeInsets.all(0),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

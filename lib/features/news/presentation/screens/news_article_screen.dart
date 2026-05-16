import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewsArticleScreen extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String imageUrl;

  const NewsArticleScreen({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, colors.surface],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassContainer(
                borderRadius: 99,
                opacity: 0.3,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GlassContainer(
                        borderRadius: 6,
                        opacity: 0.1,
                        color: colors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(color: colors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 14, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.newspaper_rounded, size: 16, color: colors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'news.source'.tr() + ': FarmZY Press',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const Divider(height: 40),
                  Text(
                    "This is a detailed simulated article body for the news item: $title.\n\n"
                    "Agriculture is the backbone of the economy, and recent advancements in agri-tech are "
                    "paving the way for more sustainable farming practices. In this article, we explore how "
                    "farmers can leverage new government subsidies and AI-driven market predictions to maximize "
                    "their yield and profitability.\n\n"
                    "By adopting modern tools, such as the FarmZY platform, farmers gain direct access to "
                    "buyers, eliminating middlemen and ensuring fair pricing. The integration of weather "
                    "forecasting and soil health monitoring further empowers decision-making, reducing risks "
                    "associated with unpredictable climate changes.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'news.related'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Mock related article
                  GlassContainer(
                    borderRadius: AppRadius.card,
                    opacity: 0.05,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: colors.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.image_outlined, color: colors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "How to optimize water usage during dry spells",
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/features/news/presentation/screens/news_article_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text('news.title'.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Featured News
          _FeaturedNewsCard(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Categories
          _SectionHeader(title: 'navigation.explore'.tr()),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(label: 'news.trending'.tr(), isActive: true),
                _CategoryChip(label: 'news.agriculture'.tr()),
                _CategoryChip(label: 'news.market_prices'.tr()),
                _CategoryChip(label: 'news.schemes'.tr()),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // News Feed
          _SectionHeader(title: 'Latest Updates'),
          const SizedBox(height: AppSpacing.md),
          _NewsTile(
            title: "New Government Subsidy for Solar Irrigation Pumps",
            category: "Schemes",
            time: "2h ago",
            imageUrl: "https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=500&auto=format&fit=crop",
          ),
          _NewsTile(
            title: "Market Alert: Onion prices expected to rise next week",
            category: "Market",
            time: "4h ago",
            imageUrl: "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?q=80&w=500&auto=format&fit=crop",
          ),
          _NewsTile(
            title: "Smart Farming: How AI is increasing crop yield by 20%",
            category: "Tech",
            time: "Yesterday",
            imageUrl: "https://images.unsplash.com/photo-1560493676-04071c5f4b52?q=80&w=500&auto=format&fit=crop",
          ),
          
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
    );
  }
}

class _FeaturedNewsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=800&auto=format&fit=crop"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  borderRadius: 6,
                  opacity: 0.2,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Text(
                    "FEATURED",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sustainable Farming Practices for the 2026 Monsoon Season",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _CategoryChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GlassContainer(
        borderRadius: 99,
        opacity: isActive ? 0.2 : 0.05,
        blur: 0,
        color: isActive ? colors.primary : colors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String imageUrl;

  const _NewsTile({
    required this.title,
    required this.category,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsArticleScreen(
                title: title,
                category: category,
                time: time,
                imageUrl: imageUrl,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: GlassContainer(
          borderRadius: AppRadius.card,
          opacity: 0.05,
          blur: 0,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(imageUrl, width: 90, height: 90, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "• $time",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

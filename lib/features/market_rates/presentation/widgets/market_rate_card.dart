import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/features/market_rates/data/models/market_rate.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';

class MarketRateCard extends StatelessWidget {
  final MarketRate rate;

  const MarketRateCard({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lang = context.locale.languageCode;

    final translatedName = rate.translations?.getTranslatedField(
          'cropName',
          lang,
          original: rate.cropName,
        ) ??
        rate.cropName;

    final isUp = rate.trend == 'UP';
    final isDown = rate.trend == 'DOWN';
    final trendColor = isUp
        ? Colors.greenAccent
        : isDown
            ? Colors.redAccent
            : colors.onSurfaceVariant.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GlassContainer(
        borderRadius: 24,
        opacity: 0.05,
        blur: 20,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translatedName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (rate.variety != null && rate.variety!.isNotEmpty)
                        Text(
                          rate.variety!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                _TrendIndicator(
                  trend: rate.trend,
                  percentage: rate.changePercentage,
                  color: trendColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${rate.currentPrice.toInt()}",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "/ ${rate.unit}",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (rate.minPrice != null && rate.maxPrice != null)
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'market_rates.range'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "₹${rate.minPrice!.toInt()} - ₹${rate.maxPrice!.toInt()}",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: colors.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          rate.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rate.source != null) ...[
                      _SourceBadge(source: rate.source!),
                      const SizedBox(width: 8),
                    ],
                    _DemandBadge(level: rate.demandLevel),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final String trend;
  final double percentage;
  final Color color;

  const _TrendIndicator({
    required this.trend,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = trend == 'UP';
    final isDown = trend == 'DOWN';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp
                ? Icons.trending_up_rounded
                : isDown
                    ? Icons.trending_down_rounded
                    : Icons.trending_flat_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            "${isUp ? '+' : ''}$percentage%",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemandBadge extends StatelessWidget {
  final String level;

  const _DemandBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = level == 'HIGH'
        ? Colors.orangeAccent
        : level == 'MEDIUM'
            ? Colors.blueAccent
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        level.tr(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInternal = source.contains('FarmZY');
    final color = isInternal ? theme.colorScheme.primary : Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        source.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

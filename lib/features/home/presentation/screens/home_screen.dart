/**
 * Module: Home Screen
 * Purpose: Implements the Home Screen module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/profile/providers/profile_provider.dart';
import 'package:farmzy/shared/enums/activity_type.dart';
import 'package:farmzy/shared/models/activity_model.dart';
import 'package:farmzy/shared/utils/activity_ui_mapper.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/premium_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:farmzy/features/market_rates/providers/market_rates_provider.dart';
import 'package:farmzy/shared/widgets/feature_guard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);

    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(theme, profileAsync),
                      const SizedBox(height: 24),
                      _searchBar(theme),
                      const SizedBox(height: 24),
                      _weatherCard(theme),
                      const SizedBox(height: 32),
                      FeatureGuard(
                        featureKey: 'marketRates',
                        child: _marketPrices(theme),
                      ),
                      const SizedBox(height: 32),
                      _quickActions(theme),
                      const SizedBox(height: 32),
                      FeatureGuard(
                        featureKey: 'marketplace',
                        child: _sellCropCTA(theme),
                      ),
                      const SizedBox(height: 32),
                      _recentActivity(theme),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, AsyncValue profileAsync) {
    return profileAsync.maybeWhen(
      data: (profile) => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "home.greeting".tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  fontSize: 26,
                ),
              ),
            ],
          ),
          const Spacer(),
          Hero(
            tag: 'profile_avatar',
            child: GlassContainer(
              borderRadius: 99,
              padding: const EdgeInsets.all(3),
              opacity: 0.1,
              blur: 10,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                backgroundImage: profile.profileImage != null
                    ? CachedNetworkImageProvider(profile.profileImage!)
                    : null,
                child: profile.profileImage == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ),
          ).animate().scale(
            delay: 200.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _searchBar(ThemeData theme) {
    return PremiumSearchBar(
          controller:
              TextEditingController(), // TODO: Add proper search logic if needed
          hintText: "home.search_hint".tr(),
          suffix: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _weatherCard(ThemeData theme) {
    final colors = theme.colorScheme;
    return GlassContainer(
          borderRadius: 32,
          opacity: 0.85,
          blur: 30,
          color: colors.primary,
          padding: const EdgeInsets.all(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "26°C",
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'home.weather.location'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'home.weather.cloudy'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.wb_cloudy_rounded, size: 72, color: Colors.white)
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .moveY(
                    begin: -6,
                    end: 6,
                    duration: 2.seconds,
                    curve: Curves.easeInOutSine,
                  )
                  .shimmer(
                    delay: 1.seconds,
                    duration: 2.seconds,
                    color: Colors.white24,
                  ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _marketPrices(ThemeData theme) {
    final marketState = ref.watch(marketRatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          theme,
          "home.market_prices.title".tr(),
          onViewAll: () => context.push(RouteNames.marketRates),
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            if (marketState.isLoading && marketState.rates.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (marketState.error != null && marketState.rates.isEmpty) {
              return const SizedBox.shrink();
            }

            final previewRates = marketState.rates.take(3).toList();
            if (previewRates.isEmpty) return const SizedBox.shrink();

            return Column(
              children: previewRates.map((item) {
                final today = item.currentPrice;
                final change = item.changePercentage;
                final isUp = item.trend == 'UP';

                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  opacity: 0.03,
                  blur: 0,
                  child: Row(
                    children: [
                      GlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(10),
                        color: theme.colorScheme.primary,
                        opacity: 0.1,
                        blur: 0,
                        child: Icon(
                          Icons.eco_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.cropName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              item.location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${today.toInt()}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 14,
                                color: isUp ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${isUp ? '+' : ''}${change.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: isUp ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 100.ms * previewRates.indexOf(item))
                    .slideX(begin: 0.05, end: 0);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _quickActions(ThemeData theme) {
    final actions = [
      {
        "icon": Icons.agriculture_rounded,
        "title": "home.quick_actions.my_crops".tr(),
        "route": RouteNames.myCrops,
        "color": Colors.green,
        "featureKey": "myCrops",
      },
      {
        "icon": Icons.shopping_bag_rounded,
        "title": "home.quick_actions.orders".tr(),
        "route": RouteNames.orders,
        "color": Colors.orange,
        "featureKey": "orders",
      },
      {
        "icon": Icons.account_balance_wallet_rounded,
        "title": "Wallet",
        "route": RouteNames.profile,
        "color": Colors.blue,
        "featureKey": null,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(theme, "home.quick_actions.title".tr()),
        const SizedBox(height: 16),
        Row(
          children: actions.map((e) {
            final color = e["color"] as Color;
            return Expanded(
              child: FeatureGuard(
                featureKey: e["featureKey"] as String?,
                child: GestureDetector(
                  onTap: () => context.go(e["route"] as String),
                  child: GlassContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    borderRadius: 28,
                    opacity: 0.03,
                    blur: 0,
                    child: Column(
                      children: [
                        GlassContainer(
                          borderRadius: 99,
                          padding: const EdgeInsets.all(12),
                          color: color,
                          opacity: 0.15,
                          blur: 0,
                          child: Icon(
                            e["icon"] as IconData,
                            color: color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          e["title"] as String,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _sellCropCTA(ThemeData theme) {
    final colors = theme.colorScheme;
    return GlassContainer(
      borderRadius: AppRadius.card,
      opacity: 0.08,
      color: colors.primary,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(RouteNames.marketplace),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "home.sell_crop".tr(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "List your harvest on Marketplace",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().shimmer(
      delay: 3.seconds,
      duration: 2.seconds,
      color: colors.primary.withValues(alpha: 0.1),
    );
  }

  Widget _recentActivity(ThemeData theme) {
    final activities = [
      Activity(
        title: "Payment received from BigBasket",
        type: ActivityType.paymentReceived,
        referenceId: "PAY123",
      ),
      Activity(
        title: "Crop approved: Alfonso Mango",
        type: ActivityType.cropApproved,
        referenceId: "CRP456",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(theme, "home.recent_activity.title".tr()),
        const SizedBox(height: 16),
        ...activities.map((activity) {
          final icon = ActivityUIMapper.getIcon(activity.type);
          final color = ActivityUIMapper.getColor(activity.type);

          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            borderRadius: 24,
            opacity: 0.02,
            blur: 0,
            child: ListTile(
              leading: GlassContainer(
                borderRadius: 12,
                padding: const EdgeInsets.all(8),
                color: color,
                opacity: 0.1,
                blur: 0,
                child: Icon(icon, color: color, size: 22),
              ),
              title: Text(
                activity.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              onTap: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _sectionHeader(ThemeData theme, String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
          child: Row(
            children: [
              Text(
                "common.view_all".tr(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12),
            ],
          ),
        ),
      ],
    );
  }
}

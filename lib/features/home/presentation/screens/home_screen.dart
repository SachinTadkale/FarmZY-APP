import 'package:farmzy/shared/enums/activity_type.dart';
import 'package:farmzy/shared/models/activity_model.dart';
import 'package:farmzy/shared/utils/activity_ui_mapper.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween(
      begin: const Offset(0, .05),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// HEADER
              _header(theme),

              const SizedBox(height: 20),

              /// SEARCH
              _searchBar(theme),

              const SizedBox(height: 20),

              /// WEATHER
              _weatherCard(theme),

              const SizedBox(height: 20),

              _marketPrices(theme),

              const SizedBox(height: 20),

              /// SELL CTA
              _sellCropCTA(theme),

              const SizedBox(height: 24),

              /// QUICK ACTIONS
              _quickActions(theme),

              const SizedBox(height: 24),

              /// RECENT ACTIVITY
              _recentActivity(theme),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActivityTap(Activity activity) {
  switch (activity.type) {

    case ActivityType.companyRequest:
      context.push("/requests/${activity.referenceId}");
      break;

    case ActivityType.orderPicked:
      context.push("/orders/${activity.referenceId}");
      break;

    case ActivityType.paymentReceived:
      context.push("/wallet/${activity.referenceId}");
      break;

    case ActivityType.deliveryCompleted:
      context.push("/delivery/${activity.referenceId}");
      break;

    case ActivityType.cropApproved:
      context.push("/crops/${activity.referenceId}");
      break;
  }
}
  /// HEADER

  Widget _header(ThemeData theme) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage("assets/avatar.png"),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, Maruti 👋",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text("Farmer • Maharashtra", style: theme.textTheme.bodySmall),
            ],
          ),
        ),

        IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ],
    );
  }

  /// SEARCH BAR

  Widget _searchBar(ThemeData theme) {
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: colors.primary),
          hintText: "Search crops, companies...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// WEATHER CARD

  Widget _weatherCard(ThemeData theme) {
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_cloudy, size: 30, color: colors.primary),

          const SizedBox(width: 12),

          Text("26° Cloudy", style: theme.textTheme.titleMedium),

          const Spacer(),

          Text("H:28°  L:24°", style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  /// Market Price

  Widget _marketPrices(ThemeData theme) {
    final data = [
      {"crop": "Tomato", "today": 50, "yesterday": 47},
      {"crop": "Mango", "today": 100, "yesterday": 102},
      {"crop": "Rice", "today": 60, "yesterday": 60},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Market Prices", style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              /// HEADER
              Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Crop"),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Current"),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Previous"),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("Change"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(),

              /// ROWS
              ...data.map((item) {
                double today = (item["today"] as num).toDouble();
                double yesterday = (item["yesterday"] as num).toDouble();

                double change = ((today - yesterday) / yesterday) * 100;

                Color color = change > 0
                    ? Colors.green
                    : change < 0
                    ? Colors.red
                    : Colors.grey;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      /// Crop
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item["crop"] as String),
                        ),
                      ),

                      /// Current
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("₹${today.toInt()}"),
                        ),
                      ),

                      /// Previous
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("₹${yesterday.toInt()}"),
                        ),
                      ),

                      /// Change
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${change.toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// SELL CROP BUTTON

  Widget _sellCropCTA(ThemeData theme) {
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Sell Your Crop",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// QUICK ACTIONS

  Widget _quickActions(ThemeData theme) {
    final colors = theme.colorScheme;

    final actions = [
      {"icon": Icons.agriculture, "title": "My Crops"},
      {"icon": Icons.shopping_cart, "title": "Orders"},
      {"icon": Icons.account_balance_wallet, "title": "Wallet"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: theme.textTheme.titleMedium),

        const SizedBox(height: 12),

        Row(
          children: actions.map((e) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(e["icon"] as IconData, color: colors.primary),

                    const SizedBox(height: 8),

                    Text(e["title"] as String),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// RECENT ACTIVITY

  Widget _recentActivity(ThemeData theme) {
    final activities = [
      Activity(
        title: "Company requested 500kg Tomato",
        type: ActivityType.companyRequest,
        referenceId: "REQ101",
      ),
      Activity(
        title: "Order #102 picked up",
        type: ActivityType.orderPicked,
        referenceId: "ORD102",
      ),
      Activity(
        title: "₹5000 received from FreshFoods",
        type: ActivityType.paymentReceived,
        referenceId: "PAY889",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Activity", style: theme.textTheme.titleMedium),

        const SizedBox(height: 12),

        ...activities.map((activity) {
          /// Get icon & color automatically
          final icon = ActivityUIMapper.getIcon(activity.type);
          final color = ActivityUIMapper.getColor(activity.type);

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _handleActivityTap(activity);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),

                  const SizedBox(width: 12),

                  /// TEXT
                  Expanded(
                    child: Text(
                      activity.title,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),

                  /// ARROW
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

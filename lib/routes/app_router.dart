import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/language_selection_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/login_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/register_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/verification_pending_screen.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/features/delivery_partner/presentation/screens/delivery_jobs_screen.dart';
import 'package:farmzy/features/delivery_partner/presentation/screens/delivery_partner_home_screen.dart';
import 'package:farmzy/features/ai/presentation/screens/ai_screen.dart';
import 'package:farmzy/features/news/presentation/screens/news_screen.dart';
import 'package:farmzy/features/help/presentation/screens/help_screen.dart';
import 'package:farmzy/features/home/presentation/screens/home_screen.dart';
import 'package:farmzy/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:farmzy/features/maintenance/providers/maintenance_provider.dart';
import 'package:farmzy/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:farmzy/features/marketplace/presentation/screens/listing_detail_screen.dart';
import 'package:farmzy/features/market_rates/presentation/screens/market_rates_screen.dart';
import 'package:farmzy/features/my_crops/presentation/screens/my_crops_screen.dart';
import 'package:farmzy/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:farmzy/features/orders/presentation/screens/orders_screen.dart';
import 'package:farmzy/features/profile/presentation/screens/profile_screen.dart';
import 'package:farmzy/features/profile/presentation/screens/profile_qr_screen.dart';
import 'package:farmzy/features/settings/presentation/screens/settings_screen.dart';
import 'package:farmzy/features/splash/presentation/splash_screen.dart';
import 'package:farmzy/features/transaction/presentation/screens/transaction_history_screen.dart';
import 'package:farmzy/features/profile/data/models/farmer_profile.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/layouts/main_layout.dart';
import 'package:farmzy/shared/widgets/feature_unavailable_screen.dart';
import 'package:farmzy/features/settings/providers/app_config_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(
    ref.read(authControllerProvider),
  );

  ref.onDispose(authNotifier.dispose);

  ref.listen<AuthState>(authControllerProvider, (_, next) {
    authNotifier.value = next;
  });

  ref.listen<int>(authInvalidationProvider, (_, next) {
    if (next > 0) {
      ref.read(authControllerProvider.notifier).logout();
    }
  });

  // Maintenance state notifier — used to trigger router refresh
  final maintenanceNotifier = ValueNotifier<MaintenanceState>(
    ref.read(maintenanceProvider),
  );
  ref.listen<MaintenanceState>(maintenanceProvider, (_, next) {
    maintenanceNotifier.value = next;
  });

  // App Config notifier — used to trigger router refresh when flags change
  final appConfigNotifier = ValueNotifier<AppConfigState>(
    ref.read(appConfigProvider),
  );
  ref.listen<AppConfigState>(appConfigProvider, (_, next) {
    appConfigNotifier.value = next;
  });

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: Listenable.merge([
      authNotifier,
      maintenanceNotifier,
      appConfigNotifier,
    ]),
    redirect: (context, state) {
      final currentPath = state.uri.path;
      
      // 1. ABSOLUTE PRIORITY: Maintenance
      final maintenanceState = ref.read(maintenanceProvider);
      if (maintenanceState.isInMaintenance || maintenanceState.isReadOnly) {
        if (kDebugMode) debugPrint('🚩 ROUTER: Maintenance Mode Active. Current: $currentPath');
        if (currentPath != RouteNames.maintenance) return RouteNames.maintenance;
        return null;
      }

      // 2. ABSOLUTE PRIORITY: Return from Maintenance
      final appConfigState = ref.read(appConfigProvider);
      if (currentPath == RouteNames.maintenance) {
        if (!maintenanceState.isInMaintenance && !appConfigState.config.maintenanceMode) {
          if (kDebugMode) debugPrint('🚩 ROUTER: Maintenance Over. Redirecting to Splash');
          return RouteNames.splash;
        }
        return null;
      }

      // 3. INITIALIZATION GUARD
      final authState = ref.read(authControllerProvider);
      if (!appConfigState.isInitialized || !authState.isInitialized) {
        if (kDebugMode) {
          debugPrint('🚩 ROUTER: Waiting for Init... Config: ${appConfigState.isInitialized}, Auth: ${authState.isInitialized}');
        }
        return currentPath == RouteNames.splash ? null : RouteNames.splash;
      }

      // 4. FEATURE GUARDS
      final appConfig = appConfigState.config;
      final featureRoutes = {
        RouteNames.marketplace: 'marketplace',
        RouteNames.orders:      'orders',
        RouteNames.marketRates: 'marketRates',
        RouteNames.aiChat:      'ai',
        RouteNames.news:        'news',
      };

      for (final entry in featureRoutes.entries) {
        if (currentPath.startsWith(entry.key)) {
          final fKey = entry.value;
          if (!appConfig.isVisible(fKey) || !appConfig.isEnabled(fKey)) {
            final name = fKey[0].toUpperCase() + fKey.substring(1);
            final isSoon = appConfig.isVisible(fKey) && !appConfig.isEnabled(fKey);
            return '/feature-unavailable?name=$name&soon=$isSoon';
          }
        }
      }

      if (currentPath == '/feature-unavailable') return null;

      // 5. PUBLIC ROUTES
      final isPublicRoute = <String>{
        RouteNames.languageSelection,
        RouteNames.roleSelection,
        RouteNames.login,
        RouteNames.register,
        RouteNames.farmerRegister,
        RouteNames.deliveryRegister,
        RouteNames.forgotPassword,
        RouteNames.otpVerification,
        RouteNames.resetPassword,
      }.contains(currentPath);

      if (!authState.hasToken) {
        if (currentPath == RouteNames.splash) {
          return RouteNames.languageSelection;
        }
        if (isPublicRoute) {
          return null;
        }
        return RouteNames.roleSelection;
      }

      if (authState.requiresOnboarding) {
        return currentPath == RouteNames.onboarding
            ? null
            : RouteNames.onboarding;
      }

      if (authState.requiresVerification) {
        return currentPath == RouteNames.verificationPending
            ? null
            : RouteNames.verificationPending;
      }

      final homeRoute = RouteNames.homeForRole(authState.role);
      if (currentPath == RouteNames.home) {
        return homeRoute;
      }

      final isAllowedLocation = authState.role == UserRole.deliveryPartner
          ? currentPath == RouteNames.deliveryHome ||
                currentPath == RouteNames.deliveryJobs ||
                currentPath == RouteNames.deliveryDeliveries ||
                currentPath == RouteNames.profile ||
                currentPath == RouteNames.transactionHistory ||
                currentPath == RouteNames.settings ||
                currentPath == RouteNames.languageSelection
          : currentPath == RouteNames.farmerHome ||
                currentPath == RouteNames.marketplace ||
                currentPath.startsWith('/marketplace/') ||
                currentPath == RouteNames.marketRates ||
                currentPath == RouteNames.myCrops ||
                currentPath == RouteNames.orders ||
                currentPath.startsWith('/orders/') ||
                currentPath == RouteNames.profile ||
                currentPath == RouteNames.profileQr ||
                currentPath == RouteNames.transactionHistory ||
                currentPath == RouteNames.settings ||
                currentPath == RouteNames.aiChat ||
                currentPath == RouteNames.news ||
                currentPath == RouteNames.help ||
                currentPath == RouteNames.languageSelection;

      if (!isAllowedLocation) {
        return homeRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/feature-unavailable',
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? 'Feature';
          final isSoon = state.uri.queryParameters['soon'] == 'true';
          return FeatureUnavailableScreen(featureName: name, isComingSoon: isSoon);
        },
      ),
      GoRoute(
        path: RouteNames.maintenance,
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.farmerRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.deliveryRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            email: (extra?['email'] ?? '').toString(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResetPasswordScreen(
            email: (extra?['email'] ?? '').toString(),
            otp: (extra?['otp'] ?? '').toString(),
          );
        },
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.verificationPending,
        builder: (context, state) => const VerificationPendingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.farmerHome,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.deliveryHome,
            builder: (context, state) => const DeliveryPartnerHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.deliveryJobs,
            builder: (context, state) => const DeliveryJobsScreen(),
          ),
          GoRoute(
            path: RouteNames.deliveryDeliveries,
            builder: (context, state) => const DeliveryDeliveriesScreen(),
          ),
          GoRoute(
            path: RouteNames.marketplace,
            builder: (context, state) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: RouteNames.listingDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ListingDetailScreen(listingId: id);
            },
          ),
          GoRoute(
            path: RouteNames.marketRates,
            builder: (context, state) => const MarketRatesScreen(),
          ),
          GoRoute(
            path: RouteNames.myCrops,
            builder: (context, state) => const MyCropsScreen(),
          ),
          GoRoute(
            path: RouteNames.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.orderDetail,
        builder: (context, state) {
          final id = (state.pathParameters['id'] ?? '').toString();
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.profileQr,
        builder: (context, state) {
          final extra = state.extra as FarmerProfile?;
          if (extra == null) return const SizedBox.shrink(); // Safety
          return ProfileQrScreen(profile: extra);
        },
      ),
      GoRoute(
        path: RouteNames.myCrops,
        builder: (context, state) => const MyCropsScreen(),
      ),
      GoRoute(
        path: RouteNames.aiChat,
        builder: (context, state) => const AIScreen(),
      ),
      GoRoute(
        path: RouteNames.news,
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: RouteNames.help,
        builder: (context, state) => const HelpScreen(),
      ),
    ],
  );
});

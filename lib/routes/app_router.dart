import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/register_flow_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:farmzy/features/home/presentation/screens/home_screen.dart';
import 'package:farmzy/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:farmzy/features/my_crops/presentation/screens/my_crops_screen.dart';
import 'package:farmzy/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:farmzy/features/orders/presentation/screens/orders_screen.dart';
import 'package:farmzy/features/profile/presentation/screens/profile_screen.dart';
import 'package:farmzy/features/splash/presentation/splash_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/login_screen.dart';
import 'package:farmzy/features/auth/providers/auth_provider.dart';
import 'package:farmzy/features/transaction/presentation/screens/transaction_history_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:farmzy/shared/layouts/main_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(ref.read(authProvider));
  ref.onDispose(authNotifier.dispose);
  ref.listen<bool>(authProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authNotifier,

    redirect: (context, state) {
      final isLoggedIn = authNotifier.value;
      final isGoingToLogin = state.fullPath == RouteNames.login;
      final isGoingToRegister = state.fullPath == RouteNames.register;

      // 🔐 Protect private routes only
      if (!isLoggedIn &&
          !isGoingToLogin &&
          !isGoingToRegister &&
          state.fullPath != RouteNames.splash &&
          state.fullPath != RouteNames.forgotPassword &&
          state.fullPath != RouteNames.otpVerification &&
          state.fullPath != RouteNames.resetPassword) {
        return RouteNames.login;
      }

      // Prevent logged-in users from going back to login/register
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return RouteNames.home;
      }

      return null;
    },

    routes: [
      /// Splash
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      /// Auth
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterFlowScreen(),
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
            path: RouteNames.marketplace,
            builder: (context, state) => const MarketplaceScreen(),
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
            path: RouteNames.orderDetail,
            builder: (context, state) {
              final id = (state.pathParameters['id'] ?? '').toString();
              return OrderDetailScreen(orderId: id);
            },
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),

          GoRoute(
            path: RouteNames.transactionHistory,
            builder: (context, state) => const TransactionHistoryScreen(),
          ),
        ],
      ),
    ],
  );
});

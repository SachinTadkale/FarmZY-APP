import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/register_flow_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:farmzy/features/home/presentation/screens/home_screen.dart';
import 'package:farmzy/features/splash/presentation/screens/splash_screen.dart';
import 'package:farmzy/features/auth/presentation/screens/login_screen.dart';
import 'package:farmzy/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,

    redirect: (context, state) {
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
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      /// Home (add your HomeScreen here)
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
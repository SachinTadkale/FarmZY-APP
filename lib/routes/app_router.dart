import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/auth/presentation/screens/register_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,

    redirect: (context, state) {
      final isGoingToLogin = state.fullPath == RouteNames.login;

      // NOT logged in → go to login
      if (!isLoggedIn && !isGoingToLogin) {
        return RouteNames.login;
      }

      // Logged in → skip login
      if (isLoggedIn && isGoingToLogin) {
        return RouteNames.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // GoRoute(
      //   path: '/home',
      //   builder: (context, state) => const HomeScreen(),
      // ),
    ],
  );
});

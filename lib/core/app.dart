import 'package:farmzy/core/theme/app_theme.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmZY extends ConsumerWidget {
  const FarmZY({super.key});
  static bool _initialized = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    if (!_initialized) {
      _initialized = true;

      Future.microtask(() {
        ref.read(authControllerProvider.notifier).restoreSession();
      });
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FarmZY',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

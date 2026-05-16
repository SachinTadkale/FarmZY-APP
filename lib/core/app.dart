/**
 * Module: FarmZy Root App Widget
 * Purpose: Connects routing, theming, and session restoration for the mobile app.
 */
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_theme.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/features/settings/providers/settings_controller.dart';
import 'package:farmzy/shared/widgets/maintenance_guard.dart';

/**
 * Farm Zy.
 */
class FarmZY extends ConsumerStatefulWidget {
  const FarmZY({super.key});

  @override
  ConsumerState<FarmZY> createState() => _FarmZYState();
}

/**
 * Farm Zystate.
 */
class _FarmZYState extends ConsumerState<FarmZY> {
  @override
  /**
 * Init State.
 */
  void initState() {
    super.initState();
    // Restore the cached session as soon as the root widget is mounted.
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).restoreSession();
    });
  }

  @override
  /**
 * Build.
 */
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authControllerProvider);
    final selectedRole = ref.watch(selectedRoleProvider);
    final activeThemeRole = selectedRole ?? authState.role;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FarmZY',

      /// 🔥 ADD THESE 3 LINES
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      theme: AppTheme.getTheme(activeThemeRole),
      darkTheme: AppTheme.getDarkTheme(activeThemeRole),
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}

import 'package:farmzy/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:farmzy/features/maintenance/providers/maintenance_provider.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/settings/providers/app_config_provider.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceGuard extends ConsumerWidget {
  final Widget child;

  const MaintenanceGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceState = ref.watch(maintenanceProvider);
    final configState = ref.watch(appConfigProvider);
    final authState = ref.watch(authControllerProvider);
    
    // ── 1. Bypass Logic ──────────────────────────────────────────────────────
    final isPrivileged = authState.hasToken && 
        (authState.role == UserRole.owner || authState.role == UserRole.admin);

    // ── 2. Initialization phase ──────────────────────────────────────────────
    // We must wait for the configuration to be fetched at least once.
    if (!configState.isInitialized) {
      return const SizedBox.shrink(); // Router will show Splash via its own logic
    }

    // ── 3. Maintenance Block ──────────────────────────────────────────────────
    if (maintenanceState.isInMaintenance && !isPrivileged) {
      return const MaintenanceScreen();
    }

    // ── 3. Normal App Tree ────────────────────────────────────────────────────
    return child;
  }
}

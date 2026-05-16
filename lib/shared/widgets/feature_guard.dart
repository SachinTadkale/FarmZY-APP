import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/features/settings/providers/app_config_provider.dart';

enum FeatureGuardMode {
  hide,
  disable,
  comingSoon,
}

class FeatureGuard extends ConsumerWidget {
  final String? featureKey;
  final Widget child;
  final FeatureGuardMode fallbackMode;
  final Widget? placeholder;

  const FeatureGuard({
    super.key,
    this.featureKey,
    required this.child,
    this.fallbackMode = FeatureGuardMode.hide,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = featureKey;
    if (key == null) return child;
    final config = ref.watch(appConfigProvider).config;
    
    final isVisible = config.isVisible(key);
    final isEnabled = config.isEnabled(key);

    if (!isVisible) {
      return placeholder ?? const SizedBox.shrink();
    }

    if (!isEnabled) {
      if (fallbackMode == FeatureGuardMode.hide) {
        return placeholder ?? const SizedBox.shrink();
      }
      
      // Disable interaction and reduce opacity
      return AbsorbPointer(
        child: Opacity(
          opacity: 0.5,
          child: child,
        ),
      );
    }

    return child;
  }
}

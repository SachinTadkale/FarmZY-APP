import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';

class AuthGlassCard extends StatelessWidget {
  final Widget child;
  final double? opacity;
  final double? blur;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool showBorder;
  final Border? border;

  const AuthGlassCard({
    super.key,
    required this.child,
    this.opacity,
    this.blur,
    this.padding,
    this.borderRadius,
    this.showBorder = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      borderRadius: borderRadius ?? AppRadius.card,
      opacity: opacity ?? 0.05,
      blur: blur ?? 30,
      border: showBorder 
        ? (border ?? Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ))
        : Border.all(color: Colors.transparent, width: 0),
      child: child,
    );
  }
}

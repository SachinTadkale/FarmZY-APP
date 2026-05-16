import 'dart:ui';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      children: [
        // --- Premium Background Mesh (Synced with AppScaffold) ---
        Positioned.fill(
          child: Container(color: theme.scaffoldBackgroundColor),
        ),
        Positioned(
          top: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.secondary.withValues(alpha: 0.08),
            ),
          ),
        ),
        // Blur layer to soften the circles
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),

        /// MAIN CONTENT
        Positioned.fill(child: child),
      ],
    );
  }
}

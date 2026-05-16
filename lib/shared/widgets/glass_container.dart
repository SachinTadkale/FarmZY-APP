import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final BorderRadiusGeometry? customBorderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final bool isHoverable;
  final BoxShape shape;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.customBorderRadius,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.border,
    this.isHoverable = false,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final glassColor = color ?? (isDark ? Colors.white : Colors.black);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: shape == BoxShape.circle 
          ? null 
          : (customBorderRadius ?? BorderRadius.circular(borderRadius)),
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape == BoxShape.circle 
          ? BorderRadius.circular(999) 
          : (customBorderRadius ?? BorderRadius.circular(borderRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: glassColor.withValues(alpha: opacity),
              borderRadius: shape == BoxShape.circle 
                ? null 
                : (customBorderRadius ?? BorderRadius.circular(borderRadius)),
              shape: shape,
              border: border ?? Border.all(
                color: borderColor,
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glassColor.withValues(alpha: opacity * 1.5),
                  glassColor.withValues(alpha: opacity * 0.5),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

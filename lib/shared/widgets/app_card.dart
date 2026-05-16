import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool isSelected;
  final Color? accentColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.isSelected = false,
    this.accentColor,
    this.onTap,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.accentColor ?? theme.colorScheme.primary;

    final card = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: GlassContainer(
        padding: widget.padding,
        borderRadius: AppRadius.card,
        color: widget.isSelected ? accent.withValues(alpha: 0.1) : widget.color,
        opacity: widget.isSelected ? 0.2 : 0.05,
        blur: widget.isSelected ? 15 : 20,
        border: Border.all(
          color: widget.isSelected ? accent : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    
    return card;
  }
}

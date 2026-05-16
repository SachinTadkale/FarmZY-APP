import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_animations.dart';

enum AppButtonVariant {
  primary,
  outline,
  ghost,
  danger,
}

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double? width;
  final double? height;
  final Color? color;
  final bool isOutlined; // For backward compatibility

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height,
    this.color,
    this.isOutlined = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isThrottled = false;

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading || _isThrottled) return;

    setState(() => _isThrottled = true);
    widget.onPressed!();

    // Prevent rapid taps
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isThrottled = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDisabled = widget.onPressed == null || widget.isLoading || _isThrottled;

    // Resolve variant (handle backward compatibility for isOutlined)
    final effectiveVariant = widget.isOutlined ? AppButtonVariant.outline : widget.variant;

    Color bgColor;
    Color textColor;
    Border? border;

    switch (effectiveVariant) {
      case AppButtonVariant.primary:
        bgColor = widget.color ?? colors.primary;
        textColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = widget.color ?? colors.primary;
        border = Border.all(color: textColor.withValues(alpha: 0.5), width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = widget.color ?? colors.primary;
        break;
      case AppButtonVariant.danger:
        bgColor = colors.error;
        textColor = Colors.white;
        break;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: AppAnimations.fast,
      curve: AppAnimations.curve,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.6 : 1.0,
        duration: AppAnimations.normal,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: effectiveVariant == AppButtonVariant.primary && !isDisabled
                ? [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _handleTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              borderRadius: BorderRadius.circular(AppRadius.button),
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  color: bgColor,
                  border: border,
                  gradient: effectiveVariant == AppButtonVariant.primary
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            bgColor.withValues(alpha: 0.9),
                            bgColor,
                          ],
                        )
                      : null,
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: textColor,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: textColor, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              widget.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

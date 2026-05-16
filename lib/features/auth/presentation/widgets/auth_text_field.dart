import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_animations.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.nextFocusNode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _internalFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: _isFocused ? colors.primary : colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            color: Colors.transparent,
            border: Border.all(
              color: _isFocused
                  ? colors.primary.withValues(alpha: 0.5)
                  : colors.primary.withValues(alpha: 0.12),
              width: 1.1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _internalFocusNode,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction:
                widget.textInputAction ??
                (widget.nextFocusNode != null
                    ? TextInputAction.next
                    : TextInputAction.done),
            onSubmitted: (value) {
              if (widget.nextFocusNode != null) {
                widget.nextFocusNode!.requestFocus();
              } else if (widget.onSubmitted != null) {
                widget.onSubmitted!(value);
              }
            },
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                size: 20,
                color: _isFocused ? colors.primary : colors.onSurfaceVariant,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

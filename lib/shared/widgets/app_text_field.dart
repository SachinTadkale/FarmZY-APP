import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_animations.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.nextFocusNode,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            widget.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: _isFocused ? colors.primary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              fontSize: 12,
            ),
          ),
        ),
        AnimatedContainer(
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            color: Colors.transparent,
            border: Border.all(
              color: _errorText != null
                  ? colors.error.withValues(alpha: 0.5)
                  : (_isFocused
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.primary.withValues(alpha: 0.12)),
              width: 1.1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            textAlign: widget.textAlign,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            onChanged: (val) {
              if (widget.validator != null) {
                setState(() => _errorText = widget.validator!(val));
              }
              widget.onChanged?.call(val);
            },
            onFieldSubmitted: (val) {
              if (widget.nextFocusNode != null) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              }
              widget.onSubmitted?.call(val);
            },
            textInputAction: widget.textInputAction,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? colors.primary
                          : colors.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _isFocused
                            ? colors.primary
                            : colors.onSurfaceVariant.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.sm,
            ),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

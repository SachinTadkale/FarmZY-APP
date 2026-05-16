import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'dart:ui';

class AppSidePanel extends StatelessWidget {
  final Widget child;
  final String title;
  final VoidCallback onClose;
  final List<Widget>? actions;

  const AppSidePanel({
    super.key,
    required this.child,
    required this.title,
    required this.onClose,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    List<Widget>? actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: AppSidePanel(
            title: title,
            onClose: () => Navigator.pop(context),
            actions: actions,
            child: child,
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  static Future<T?> showBuilder<T>({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext context, StateSetter setState)
    builder,
    List<Widget>? actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.centerRight,
              child: AppSidePanel(
                title: title,
                onClose: () => Navigator.pop(context),
                actions: actions,
                child: builder(context, setState),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Material(
      color: Colors.transparent,
      child: GlassContainer(
        width: isTablet ? 500 : size.width * 1,
        height: size.height,
        borderRadius: 0,
        opacity: 0.1,
        blur: 40,
        padding: EdgeInsets.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.75),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.8,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _header(theme),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: child,
                    ),
                  ),
                  if (actions != null && actions!.isNotEmpty)
                    _bottomActions(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onClose,
            child: GlassContainer(
              width: 40,
              height: 40,
              borderRadius: 20,
              opacity: 0.1,
              blur: 10,
              padding: EdgeInsets.zero,
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActions(ThemeData theme) {
    return GlassContainer(
      borderRadius: 0,
      opacity: 0.05,
      blur: 15,
      padding: const EdgeInsets.all(AppSpacing.lg),
      border: const Border(top: BorderSide(color: Colors.white10)),
      child: Row(
        children: actions!
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: actions!.length > 1 ? AppSpacing.sm : 0,
                  ),
                  child: a,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

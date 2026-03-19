import 'dart:async';

import 'package:flutter/material.dart';

enum AppSnackBarType { success, error }

class AppSnackBar {
  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;
  static Timer? _dismissTimer;

  static Future<void> show(
    BuildContext context, {
    required String message,
    required AppSnackBarType type,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSuccess = type == AppSnackBarType.success;
    final accentColor = isSuccess
        ? const Color(0xFF2E7D32)
        : (scheme.error == Colors.transparent
              ? const Color(0xFFC62828)
              : scheme.error);
    final icon = isSuccess
        ? Icons.check_circle_outline_rounded
        : Icons.error_outline_rounded;

    await _dismissCurrent(animated: false);

    final controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? scheme.surface.withValues(alpha: 0.96)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.95),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: hideCurrent,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
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
          ),
        );
      },
    );

    _currentEntry = entry;
    _currentController = controller;
    overlay.insert(entry);
    await controller.forward();

    _dismissTimer = Timer(const Duration(seconds: 3), hideCurrent);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.error);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: AppSnackBarType.success);
  }

  static void hideCurrent() {
    _dismissCurrent(animated: true);
  }

  static Future<void> _dismissCurrent({required bool animated}) async {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    final controller = _currentController;
    final entry = _currentEntry;

    _currentController = null;
    _currentEntry = null;

    if (controller == null || entry == null) {
      return;
    }

    if (animated && controller.status != AnimationStatus.dismissed) {
      try {
        await controller.reverse();
      } catch (_) {}
    }

    entry.remove();
    controller.dispose();
  }
}

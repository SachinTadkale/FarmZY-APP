import 'package:farmzy/core/theme/app.colors.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toUpperCase();
    final colors = _resolveBadgeColors(normalized, Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelFor(normalized),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }

  String _labelFor(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  _BadgeColors _resolveBadgeColors(String value, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final subtle = primary.withValues(alpha: isDark ? 0.25 : 0.14);
    final success = Colors.green;
    final warning = Colors.orange;
    final neutral = Colors.blueGrey;
    final danger = Colors.red;

    if (value == 'COMPLETED' ||
        value == 'DELIVERED' ||
        value == 'PAYMENT_RECEIVED') {
      return _BadgeColors(
        background: success.withValues(alpha: isDark ? 0.24 : 0.14),
        foreground: success.shade700,
      );
    }

    if (value == 'CANCELLED') {
      return _BadgeColors(
        background: danger.withValues(alpha: isDark ? 0.28 : 0.14),
        foreground: danger.shade700,
      );
    }

    if (value == 'PAYMENT_PENDING' || value == 'SHIPPED') {
      return _BadgeColors(
        background: warning.withValues(alpha: isDark ? 0.24 : 0.16),
        foreground: warning.shade800,
      );
    }

    if (value == 'CONFIRMED' || value == 'PROCESSING') {
      return _BadgeColors(
        background: subtle,
        foreground: primary,
      );
    }

    if (value == 'INITIATED') {
      return _BadgeColors(
        background: neutral.withValues(alpha: isDark ? 0.24 : 0.14),
        foreground: neutral.shade700,
      );
    }

    return _BadgeColors(
      background: subtle,
      foreground: primary,
    );
  }
}

class _BadgeColors {
  final Color background;
  final Color foreground;

  const _BadgeColors({
    required this.background,
    required this.foreground,
  });
}

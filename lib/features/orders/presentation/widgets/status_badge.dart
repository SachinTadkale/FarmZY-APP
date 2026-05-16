import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = status.trim().toUpperCase();
    final colors = _resolveBadgeColors(normalized, theme);

    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: colors.foreground,
      opacity: 0.15,
      blur: 5,
      border: Border.all(color: colors.foreground.withValues(alpha: 0.1)),
      child: Text(
        _labelFor(normalized),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          fontSize: 10,
        ),
      ),
    );
  }

  String _labelFor(String value) {
    return 'common.status_${value.toLowerCase()}'.tr();
  }

  _BadgeColors _resolveBadgeColors(String value, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    
    final success = Colors.green;
    final warning = Colors.orange;
    final neutral = Colors.blueGrey;
    final danger = Colors.red;

    if (value == 'COMPLETED' || value == 'DELIVERED' || value == 'PAYMENT_RECEIVED' || value == 'ACTIVE') {
      return _BadgeColors(
        foreground: isDark ? success.shade300 : success.shade700,
      );
    }

    if (value == 'CANCELLED' || value == 'CLOSED') {
      return _BadgeColors(
        foreground: isDark ? danger.shade300 : danger.shade700,
      );
    }

    if (value == 'PAYMENT_PENDING' || value == 'SHIPPED') {
      return _BadgeColors(
        foreground: isDark ? warning.shade300 : warning.shade800,
      );
    }

    if (value == 'CONFIRMED' || value == 'PROCESSING') {
      return _BadgeColors(
        foreground: primary,
      );
    }

    if (value == 'INITIATED') {
      return _BadgeColors(
        foreground: isDark ? neutral.shade300 : neutral.shade700,
      );
    }

    return _BadgeColors(
      foreground: primary,
    );
  }
}

class _BadgeColors {
  final Color foreground;

  const _BadgeColors({
    required this.foreground,
  });
}

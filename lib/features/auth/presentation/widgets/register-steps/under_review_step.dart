import 'package:flutter/material.dart';

class UnderReviewStep extends StatelessWidget {
  const UnderReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        key: const ValueKey(4),
        children: [
          const SizedBox(height: 40),
          Icon(Icons.check_circle, size: 90, color: primary),
          const SizedBox(height: 20),
          Text(
            "Your account is under verification",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            "You will be notified once approved.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
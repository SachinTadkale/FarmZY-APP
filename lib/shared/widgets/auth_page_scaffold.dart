import 'package:farmzy/features/auth/presentation/widgets/auth_background.dart';
import 'package:flutter/material.dart';
import 'package:farmzy/core/theme/app_spacing.dart';

class AuthPageScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomBar;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;

  const AuthPageScaffold({
    super.key,
    required this.body,
    this.bottomBar,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: AuthBackground(
        child: SafeArea(
          bottom: bottomBar == null,
          child: Column(
            children: [
              Expanded(child: body),
              if (bottomBar != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: SafeArea(child: bottomBar!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

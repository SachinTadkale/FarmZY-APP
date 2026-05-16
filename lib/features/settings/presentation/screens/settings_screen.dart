import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/settings/providers/settings_controller.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          // APPEARANCE SECTION
          _SectionHeader(title: 'settings.appearance'.tr()),
          _SettingsGroup(
            children: [
              _ThemeSelectionTile(
                title: 'settings.theme_light'.tr(),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateTheme(val!),
                icon: Icons.light_mode_outlined,
              ),
              _ThemeSelectionTile(
                title: 'settings.theme_dark'.tr(),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateTheme(val!),
                icon: Icons.dark_mode_outlined,
              ),
              _ThemeSelectionTile(
                title: 'settings.theme_system'.tr(),
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateTheme(val!),
                icon: Icons.settings_brightness_outlined,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // LANGUAGE SECTION
          _SectionHeader(title: 'settings.language'.tr()),
          _SettingsGroup(
            children: [
              _SettingsTile(
                title: 'settings.select_language'.tr(),
                subtitle: _getLanguageName(settings.languageCode),
                icon: Icons.language_rounded,
                onTap: () => context.push(RouteNames.languageSelection),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ACCOUNT SECTION
          _SectionHeader(title: 'Account'),
          _SettingsGroup(
            children: [
              _SettingsTile(
                title: 'Edit Profile',
                icon: Icons.person_outline_rounded,
                onTap: () => context.push(RouteNames.profile),
              ),
              _SettingsTile(
                title: 'Verification',
                icon: Icons.verified_user_outlined,
                onTap: () {},
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Verified",
                    style: TextStyle(color: colors.primary, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              _SettingsTile(
                title: 'Security',
                icon: Icons.security_rounded,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // APP SECTION
          _SectionHeader(title: 'App'),
          _SettingsGroup(
            children: [
              _SettingsTile(
                title: 'Notifications',
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
              _SettingsTile(
                title: 'About FarmZY',
                icon: Icons.info_outline_rounded,
                onTap: () {},
              ),
              _SettingsTile(
                title: 'Terms & Policies',
                icon: Icons.policy_outlined,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // SUPPORT SECTION
          _SectionHeader(title: 'Support'),
          _SettingsGroup(
            children: [
              _SettingsTile(
                title: 'Help Center',
                icon: Icons.help_outline_rounded,
                onTap: () => context.push(RouteNames.help),
              ),
              _SettingsTile(
                title: 'Contact Support',
                icon: Icons.headset_mic_outlined,
                onTap: () {},
              ),
              _SettingsTile(
                title: 'FAQs',
                icon: Icons.question_answer_outlined,
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    return switch (code) {
      'hi' => 'हिन्दी',
      'mr' => 'मराठी',
      _ => 'English',
    };
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppRadius.card,
      opacity: 0.05,
      padding: const EdgeInsets.all(4),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelectionTile extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;
  final IconData icon;

  const _ThemeSelectionTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

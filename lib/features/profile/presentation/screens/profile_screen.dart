import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/features/profile/providers/profile_provider.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_text_field.dart';
import 'package:farmzy/shared/widgets/app_side_panel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmzy/features/profile/data/models/farmer_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isPanelLoading = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(profileMutationProvider, (previous, next) {
      if (next.hasError) {
        AppSnackBar.showError(context, next.error.toString());
      } else if (next.hasValue &&
          next.value != null &&
          previous?.isLoading == true) {
        AppSnackBar.showSuccess(context, next.value!);
      }
    });

    final profileAsync = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      isLoading: _isPanelLoading,
      body: profileAsync.when(
        data: (profile) => RefreshIndicator(
          edgeOffset: 100,
          onRefresh: () async {
            ref.invalidate(profileProvider);
            return await ref.read(profileProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      _profileHeader(context, theme, profile),
                      const SizedBox(height: AppSpacing.xl),
                      _quickStatsGrid(theme, profile),
                      const SizedBox(height: AppSpacing.md),
                      _settingsTiles(context, theme, profile),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => AppErrorState(
          title: 'profile.error_load'.tr(),
          error: e,
          onRetry: () => ref.refresh(profileProvider),
        ),
      ),
    );
  }

  Widget _profileHeader(
    BuildContext context,
    ThemeData theme,
    FarmerProfile profile,
  ) {
    final colors = theme.colorScheme;

    return GlassContainer(
      borderRadius: AppRadius.card,
      opacity: 0.1,
      blur: 30,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _avatarArea(profile, theme),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'profile.verified_farmer'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.location ?? "profile.location".tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _headerButton(
                  theme,
                  'profile.edit_profile'.tr(),
                  Icons.edit_note_rounded,
                  () => _showEditProfilePanel(profile),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _headerIconButton(
                theme,
                Icons.qr_code_rounded,
                () => context.push(RouteNames.profileQr, extra: profile),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _avatarArea(FarmerProfile profile, ThemeData theme) {
    final isUpdating = ref.watch(profileMutationProvider).isLoading;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.surface,
              backgroundImage: profile.profileImage != null
                  ? CachedNetworkImageProvider(profile.profileImage!)
                  : null,
              child: profile.profileImage == null
                  ? Text(
                      profile.initials,
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (isUpdating)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: isUpdating
              ? null
              : () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    await ref
                        .read(profileMutationProvider.notifier)
                        .updateProfileImage(image);
                  }
                },
          child: GlassContainer(
            borderRadius: 99,
            padding: const EdgeInsets.all(6),
            opacity: 0.8,
            color: theme.colorScheme.primary,
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerButton(
    ThemeData theme,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: 16,
        opacity: 0.05,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton(ThemeData theme, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: 16,
        opacity: 0.05,
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _quickStatsGrid(ThemeData theme, FarmerProfile profile) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.6,
      children: [
        _statCard(
          theme,
          'profile.my_crops'.tr(),
          profile.cropCount.toString(),
          Icons.eco_rounded,
          Colors.green,
        ),
        _statCard(
          theme,
          'profile.my_listings'.tr(),
          profile.listingCount.toString(),
          Icons.storefront_rounded,
          Colors.orange,
        ),
        _statCard(
          theme,
          'profile.my_orders'.tr(),
          profile.orderCount.toString(),
          Icons.shopping_bag_rounded,
          Colors.blue,
        ),
        _statCard(
          theme,
          'profile.revenue'.tr(),
          '₹${(profile.revenue / 1000).toStringAsFixed(1)}K',
          Icons.account_balance_wallet_rounded,
          Colors.purple,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _statCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return GlassContainer(
      borderRadius: AppRadius.card,
      opacity: 0.05,
      blur: 20,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTiles(
    BuildContext context,
    ThemeData theme,
    FarmerProfile profile,
  ) {
    return Column(
      children: [
        _settingsTile(
          theme,
          Icons.settings_suggest_rounded,
          'profile.settings'.tr(),
          () => context.push(RouteNames.settings),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _settingsTile(
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: GlassContainer(
        borderRadius: AppRadius.card,
        opacity: 0.03,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            GlassContainer(
              borderRadius: 12,
              padding: const EdgeInsets.all(8),
              opacity: 0.05,
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : null,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfilePanel(FarmerProfile profile) {
    setState(() => _isPanelLoading = true);
    try {
      if (context.mounted) {
        AppSidePanel.show(
          context: context,
          title: 'profile.edit_profile'.tr(),
          actions: [
            _ProfileSaveButton(
              onPressed: () => _editFormKey.currentState?.submit(),
            ),
          ],
          child: _ProfileEditForm(key: _editFormKey, profile: profile),
        );
      }
    } finally {
      setState(() => _isPanelLoading = false);
    }
  }
}

final _editFormKey = GlobalKey<_ProfileEditFormState>();

class _ProfileSaveButton extends ConsumerWidget {
  final VoidCallback onPressed;
  const _ProfileSaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(profileMutationProvider).isLoading;
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
      ),
      child: isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text('common.save'.tr()),
    );
  }
}

class _ProfileEditForm extends ConsumerStatefulWidget {
  final FarmerProfile profile;
  const _ProfileEditForm({super.key, required this.profile});

  @override
  ConsumerState<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<_ProfileEditForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _locationController = TextEditingController(text: widget.profile.location);
    _emailController = TextEditingController(text: widget.profile.email);
  }

  void submit() => _save();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'auth.register.full_name'.tr(),
          controller: _nameController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'profile.location'.tr(),
          controller: _locationController,
          prefixIcon: Icons.location_on_outlined,
          hint: 'Village, District',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'auth.register.email'.tr(),
          controller: _emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Future<void> _save() async {
    await ref
        .read(profileMutationProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          email: _emailController.text.trim(),
        );
    if (mounted) context.pop();
  }
}

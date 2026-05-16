import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/features/profile/data/models/farmer_profile.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileQrScreen extends StatelessWidget {
  final FarmerProfile profile;

  const ProfileQrScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Fallback QR data if share token is missing
    final qrData = profile.qrShareToken ?? "farmzy://profile/${profile.userId}";

    return AppScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium QR Card
              GlassContainer(
                borderRadius: AppRadius.card,
                opacity: 0.1,
                blur: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Info in Card Header
                    Row(
                      children: [
                        _smallAvatar(profile, theme),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'profile.verified_farmer'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _headerActionIcon(Icons.share_rounded, () {}),
                        const SizedBox(width: 8),
                        _headerActionIcon(Icons.file_download_outlined, () {}),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // The QR Code
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: colors.primary,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: colors.primary,
                        ),
                      ),
                    ).animate().scale(
                      delay: 200.ms,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    Text(
                      'profile.qr_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // Close button since header is removed
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                label: Text('common.close'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant.withOpacity(0.5),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallAvatar(FarmerProfile profile, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: theme.colorScheme.surface,
        backgroundImage: profile.profileImage != null
            ? CachedNetworkImageProvider(profile.profileImage!)
            : null,
        child: profile.profileImage == null
            ? Text(
                profile.initials,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
      ),
    );
  }

  Widget _headerActionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: GlassContainer(
        borderRadius: 99,
        padding: const EdgeInsets.all(10),
        opacity: 0.05,
        child: Icon(icon, size: 18),
      ),
    );
  }
}

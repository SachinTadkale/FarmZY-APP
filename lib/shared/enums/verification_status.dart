import 'package:easy_localization/easy_localization.dart';
/**
 * Verification Status.
 */
enum VerificationStatus {
  pending,
  underReview,
  approved,
  rejected,
  unknown;

  String get apiValue => switch (this) {
        VerificationStatus.pending => 'PENDING',
        VerificationStatus.underReview => 'UNDER_REVIEW',
        VerificationStatus.approved => 'APPROVED',
        VerificationStatus.rejected => 'REJECTED',
        VerificationStatus.unknown => 'UNKNOWN',
      };

  String get displayName => switch (this) {
        VerificationStatus.pending => 'common.status_pending'.tr(),
        VerificationStatus.underReview => 'common.status_under_review'.tr(),
        VerificationStatus.approved => 'common.status_approved'.tr(),
        VerificationStatus.rejected => 'common.status_rejected'.tr(),
        VerificationStatus.unknown => 'common.status_unknown'.tr(),
      };

  static VerificationStatus fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    return switch (normalized) {
      'PENDING' => VerificationStatus.pending,
      'UNDER_REVIEW' || 'UNDERREVIEW' || 'REVIEWING' => VerificationStatus.underReview,
      'APPROVED' || 'VERIFIED' => VerificationStatus.approved,
      'REJECTED' || 'DECLINED' => VerificationStatus.rejected,
      _ => VerificationStatus.unknown,
    };
  }
}

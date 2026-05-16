import 'package:easy_localization/easy_localization.dart';

enum UserRole {
  farmer,
  deliveryPartner,
  admin,
  owner;

  String get apiValue => switch (this) {
        UserRole.farmer => 'FARMER',
        UserRole.deliveryPartner => 'DELIVERY_PARTNER',
        UserRole.admin => 'ADMIN',
        UserRole.owner => 'OWNER',
      };

  String get translationKey => switch (this) {
        UserRole.farmer => 'role.farmer',
        UserRole.deliveryPartner => 'role.delivery',
        UserRole.admin => 'role.admin',
        UserRole.owner => 'role.owner',
      };

  String get displayName => translationKey.tr();

  String get shortLabel => translationKey.tr();

  static UserRole fromApiValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    return switch (normalized) {
      'DELIVERY_PARTNER' || 'DELIVERYPARTNER' || 'PARTNER' => UserRole.deliveryPartner,
      'ADMIN' => UserRole.admin,
      'OWNER' => UserRole.owner,
      'FARMER' => UserRole.farmer,
      _ => UserRole.farmer,
    };
  }
}

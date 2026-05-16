/**
 * Module: Delivery Kyc Request
 * Purpose: Implements the Delivery Kyc Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'dart:io';

/**
 * Delivery Kyc Request.
 */
class DeliveryKycRequest {
  final String idType;
  final String idNumber;
  final File idFrontImage;
  final File? idBackImage;
  final File drivingLicenseImage;
  final File rcImage;

  const DeliveryKycRequest({
    required this.idType,
    required this.idNumber,
    required this.idFrontImage,
    this.idBackImage,
    required this.drivingLicenseImage,
    required this.rcImage,
  });
}

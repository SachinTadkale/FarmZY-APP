/**
 * Module: Kyc Request
 * Purpose: Implements the Kyc Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'dart:io';

/**
 * Kyc Request.
 */
class KycRequest {
  final String docType;
  final String docNo;
  final File frontImage;
  final File? backImage;

  KycRequest({
    required this.docType,
    required this.docNo,
    required this.frontImage,
    this.backImage,
  });
}

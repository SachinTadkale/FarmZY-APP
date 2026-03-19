import 'dart:io';

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

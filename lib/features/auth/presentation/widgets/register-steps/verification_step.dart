/**
 * Module: Verification Step
 * Purpose: Implements the Verification Step module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/**
 * Verification Step.
 */
class VerificationStep extends ConsumerStatefulWidget {
  const VerificationStep({super.key});

  @override
  ConsumerState<VerificationStep> createState() => _VerificationStepState();
}

/**
 * Verification Step State.
 */
class _VerificationStepState extends ConsumerState<VerificationStep> {
  static const double _fieldRadius = 12;

  static final RegExp _aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  final picker = ImagePicker();
  late final TextEditingController idNumberController;

  String? selectedIdType;
  File? frontImage;
  File? backImage;
  bool agreeTerms = false;

  @override
/**
 * Init State.
 */
  void initState() {
    super.initState();
    final registerState = ref.read(registerProvider);
    selectedIdType =
        registerState.idType.isEmpty ? null : registerState.idType;
    frontImage = registerState.frontImage;
    backImage = registerState.backImage;
    agreeTerms = registerState.agreeTerms;
    idNumberController = TextEditingController(text: registerState.idNumber);
  }

  @override
/**
 * Dispose.
 */
  void dispose() {
    idNumberController.dispose();
    super.dispose();
  }

/**
 * Pick Image.
 */
  Future<void> pickImage(bool isFront) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      return;
    }

    final file = File(picked.path);
    setState(() {
      if (isFront) {
        frontImage = file;
      } else {
        backImage = file;
      }
    });

    ref.read(registerProvider.notifier).updateVerificationDetails(
          frontImage: isFront ? file : null,
          backImage: isFront ? null : file,
        );
  }

/**
 * Build Upload Box.
 */
  Widget buildUploadBox({
    required File? imageFile,
    required String label,
    required VoidCallback onTap,
    required Color surface,
    required Color primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 136,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(_fieldRadius),
          border: Border.all(color: primary.withOpacity(0.3)),
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, color: primary),
                  const SizedBox(height: 6),
                  Text(label, style: const TextStyle(fontSize: 13)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(_fieldRadius),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    String? idNumberError;
    final trimmedIdNumber = idNumberController.text.trim().toUpperCase();
    if (trimmedIdNumber.isNotEmpty) {
      if (selectedIdType == 'AADHAR' && !_aadhaarRegex.hasMatch(trimmedIdNumber)) {
        idNumberError = 'onboarding.errors.aadhaar_invalid'.tr();
      } else if (selectedIdType == 'PAN' && !_panRegex.hasMatch(trimmedIdNumber)) {
        idNumberError = 'onboarding.errors.pan_invalid'.tr();
      }
    }

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('onboarding.id_verification_title'.tr(), style: theme.textTheme.titleLarge),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: selectedIdType,
              isExpanded: true,
              dropdownColor: surface,
              borderRadius: BorderRadius.circular(_fieldRadius),
              decoration: InputDecoration(
                hintText: 'onboarding.select_id_type'.tr(),
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
              ),
              items: [
                DropdownMenuItem(value: 'AADHAR', child: Text('onboarding.doc_aadhaar'.tr())),
                DropdownMenuItem(value: 'PAN', child: Text('onboarding.doc_pan'.tr())),
              ],
              onChanged: (value) {
                setState(() {
                  selectedIdType = value;
                  frontImage = null;
                  backImage = null;
                });

                ref.read(registerProvider.notifier).updateVerificationDetails(
                      idType: value,
                      clearFrontImage: true,
                      clearBackImage: true,
                    );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: idNumberController,
              onChanged: (value) {
                ref.read(registerProvider.notifier).updateVerificationDetails(
                      idNumber: value,
                    );
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'onboarding.id_number_hint'.tr(),
                prefixIcon: Icon(Icons.credit_card, color: primary),
                errorText: idNumberError,
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedIdType == 'PAN')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('onboarding.upload_pan'.tr(), style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  buildUploadBox(
                    imageFile: frontImage,
                    label: 'onboarding.pan_card_label'.tr(),
                    onTap: () => pickImage(true),
                    surface: surface,
                    primary: primary,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (selectedIdType == 'AADHAR')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'onboarding.upload_aadhaar_both'.tr(),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: buildUploadBox(
                          imageFile: frontImage,
                          label: 'onboarding.front'.tr(),
                          onTap: () => pickImage(true),
                          surface: surface,
                          primary: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildUploadBox(
                          imageFile: backImage,
                          label: 'onboarding.back'.tr(),
                          onTap: () => pickImage(false),
                          surface: surface,
                          primary: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: agreeTerms,
                  activeColor: primary,
                  onChanged: (value) {
                    setState(() {
                      agreeTerms = value ?? false;
                    });
                    ref.read(registerProvider.notifier).updateVerificationDetails(
                          agreeTerms: value ?? false,
                        );
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        agreeTerms = !agreeTerms;
                      });
                      ref.read(registerProvider.notifier).updateVerificationDetails(
                            agreeTerms: agreeTerms,
                          );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'onboarding.terms_privacy'.tr(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

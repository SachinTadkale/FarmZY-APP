import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class VerificationStep extends ConsumerStatefulWidget {
  const VerificationStep({super.key});

  @override
  ConsumerState<VerificationStep> createState() =>
      _VerificationStepState();
}

class _VerificationStepState
    extends ConsumerState<VerificationStep> {
  String? selectedIdType;
  File? frontImage;
  File? backImage;
  bool agreeTerms = false;

  final picker = ImagePicker();

  Future<void> pickImage(bool isFront) async {
    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        if (isFront) {
          frontImage = File(picked.path);
        } else {
          backImage = File(picked.path);
        }
      });
    }
  }

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
        width: double.infinity, // ✅ FULL WIDTH FIX
        height: 150,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primary.withValues(alpha: 0.3),
          ),
        ),
        child: imageFile == null
            ? Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file,
                      color: primary),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style:
                        const TextStyle(fontSize: 13),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius:
                    BorderRadius.circular(16),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "ID Verification",
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 24),

            /// ID TYPE
            DropdownButtonFormField<String>(
              value: selectedIdType,
              isExpanded: true,
              dropdownColor: surface,
              borderRadius:
                  BorderRadius.circular(16),
              decoration: InputDecoration(
                hintText: "Select ID Type",
                filled: true,
                fillColor: surface,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Aadhaar",
                  child: Text("Aadhaar"),
                ),
                DropdownMenuItem(
                  value: "PAN",
                  child: Text("PAN"),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  selectedIdType = val;
                  frontImage = null;
                  backImage = null;
                });
              },
            ),

            const SizedBox(height: 20),

            /// ID NUMBER
            TextFormField(
              decoration: InputDecoration(
                hintText: "ID Number",
                prefixIcon: Icon(
                    Icons.credit_card,
                    color: primary),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 PAN Upload (FULL WIDTH MATCHED)
            if (selectedIdType == "PAN")
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload PAN Card",
                    style:
                        theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  buildUploadBox(
                    imageFile: frontImage,
                    label: "PAN Card",
                    onTap: () => pickImage(true),
                    surface: surface,
                    primary: primary,
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            /// 🔹 Aadhaar Upload (Side-by-Side)
            if (selectedIdType == "Aadhaar")
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload Aadhaar Front & Back",
                    style:
                        theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: buildUploadBox(
                          imageFile: frontImage,
                          label: "Front",
                          onTap: () =>
                              pickImage(true),
                          surface: surface,
                          primary: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildUploadBox(
                          imageFile: backImage,
                          label: "Back",
                          onTap: () =>
                              pickImage(false),
                          surface: surface,
                          primary: primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),

            /// TERMS
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: agreeTerms,
                  activeColor: primary,
                  onChanged: (val) {
                    setState(() {
                      agreeTerms =
                          val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        agreeTerms =
                            !agreeTerms;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                              top: 12),
                      child: Text(
                        "I agree to the Terms & Conditions and Privacy Policy",
                        style: theme
                            .textTheme
                            .bodySmall,
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
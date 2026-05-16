import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/features/auth/data/model/bank_details_request.dart';
import 'package:farmzy/features/auth/data/model/delivery_kyc_request.dart';
import 'package:farmzy/features/auth/data/model/farm_request.dart';
import 'package:farmzy/features/auth/data/model/kyc_request.dart';
import 'package:farmzy/features/auth/data/model/vehicle_profile_request.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_step_header.dart';
import 'package:farmzy/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/onboarding_controller.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/widgets/app_snackbar.dart';
import 'package:farmzy/shared/widgets/auth_page_scaffold.dart';
import 'package:farmzy/shared/widgets/app_button.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/features/auth/presentation/widgets/kyc/kyc_document_card.dart';
import 'package:farmzy/shared/widgets/app_dropdown.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _picker = ImagePicker();

  // Farmer step 1
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _landController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Delivery step 1
  String _vehicleType = 'onboarding.vehicle_tractor';
  final _vehicleNumberController = TextEditingController();
  final _licenseController = TextEditingController();
  final _capacityController = TextEditingController();

  // Common bank
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();

  // Common KYC
  String _idType = 'AADHAAR';
  final _idNumberController = TextEditingController();
  File? _idFront;
  File? _idBack;
  File? _drivingLicense;
  File? _rcImage;
  bool _agreeTerms = false;

  static const _vehicleTypes = <String>[
    'onboarding.vehicle_tractor',
    'onboarding.vehicle_mini_truck',
    'onboarding.vehicle_pickup',
    'onboarding.vehicle_truck',
    'onboarding.vehicle_heavy_truck',
  ];

  String _mapVehicleToEnum(String key) {
    return switch (key) {
      'onboarding.vehicle_tractor' => 'TRACTOR',
      'onboarding.vehicle_mini_truck' => 'MINI_TRUCK',
      'onboarding.vehicle_pickup' => 'PICKUP',
      'onboarding.vehicle_truck' => 'TRUCK',
      'onboarding.vehicle_heavy_truck' => 'HEAVY_TRUCK',
      _ => 'TRUCK',
    };
  }

  @override
  void dispose() {
    _stateController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _landController.dispose();
    _pincodeController.dispose();
    _vehicleNumberController.dispose();
    _licenseController.dispose();
    _capacityController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(void Function(File file) onPicked) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    onPicked(File(image.path));
    if (mounted) setState(() {});
  }

  int get _effectiveStep {
    final step = ref.read(authControllerProvider).registrationStep;
    return step <= 0 ? 1 : step;
  }

  bool _validateCurrentStep(UserRole role) {
    switch (_effectiveStep) {
      case 1:
        if (role == UserRole.farmer) {
          if (_stateController.text.trim().isEmpty)
            return _showError('onboarding.errors.state'.tr());
          if (_districtController.text.trim().isEmpty)
            return _showError('onboarding.errors.district'.tr());
          if (_villageController.text.trim().isEmpty)
            return _showError('onboarding.errors.village'.tr());
          if (_landController.text.trim().isEmpty)
            return _showError('onboarding.errors.land'.tr());
          if (double.tryParse(_landController.text.trim()) == null)
            return _showError('onboarding.errors.land_invalid'.tr());
          if (_pincodeController.text.trim().isEmpty)
            return _showError('onboarding.errors.pincode'.tr());
          if (!RegExp(r'^\d{6}$').hasMatch(_pincodeController.text.trim()))
            return _showError('onboarding.errors.pincode_invalid'.tr());
          return true;
        }
        if (_vehicleNumberController.text.trim().isEmpty)
          return _showError('onboarding.errors.vehicle_number'.tr());
        if (_licenseController.text.trim().isEmpty)
          return _showError('onboarding.errors.license_number'.tr());
        if (_capacityController.text.trim().isEmpty)
          return _showError('onboarding.errors.capacity'.tr());
        if (double.tryParse(_capacityController.text.trim()) == null)
          return _showError('onboarding.errors.capacity_invalid'.tr());
        return true;
      case 2:
        if (_accountHolderController.text.trim().isEmpty)
          return _showError('onboarding.errors.acc_holder'.tr());
        if (_accountNumberController.text.trim().isEmpty)
          return _showError('onboarding.errors.acc_number'.tr());
        if (_bankNameController.text.trim().isEmpty)
          return _showError('onboarding.errors.bank_name'.tr());
        if (_ifscController.text.trim().isEmpty)
          return _showError('onboarding.errors.ifsc'.tr());
        return true;
      case 3:
        if (_idNumberController.text.trim().isEmpty)
          return _showError('onboarding.errors.doc_number'.tr());
        if (_idFront == null)
          return _showError('onboarding.errors.upload_front'.tr());
        if (_idType == 'AADHAAR' && _idBack == null)
          return _showError('onboarding.errors.upload_back_aadhaar'.tr());
        if (role == UserRole.deliveryPartner) {
          if (_drivingLicense == null)
            return _showError('onboarding.errors.upload_license'.tr());
          if (_rcImage == null)
            return _showError('onboarding.errors.upload_rc'.tr());
        }
        if (!_agreeTerms)
          return _showError('onboarding.errors.agree_terms'.tr());
        return true;
      default:
        return true;
    }
  }

  bool _showError(String message) {
    AppSnackBar.showError(context, message);
    return false;
  }

  Future<void> _submitStep() async {
    final role = ref.read(authControllerProvider).role;
    if (!_validateCurrentStep(role)) return;
    final onboarding = ref.read(onboardingControllerProvider.notifier);

    switch (_effectiveStep) {
      case 1:
        if (role == UserRole.farmer) {
          await onboarding.submitFarmerFarmDetails(
            FarmRequest(
              state: _stateController.text.trim(),
              district: _districtController.text.trim(),
              village: _villageController.text.trim(),
              pincode: _pincodeController.text.trim(),
              landArea: double.tryParse(_landController.text.trim()),
            ),
          );
        } else {
          await onboarding.submitDeliveryVehicleDetails(
            VehicleProfileRequest(
              vehicleType: _mapVehicleToEnum(_vehicleType),
              vehicleNumber: _vehicleNumberController.text.trim(),
              licenseNumber: _licenseController.text.trim(),
              capacity: double.parse(_capacityController.text.trim()),
            ),
          );
        }
        break;
      case 2:
        await onboarding.submitBankDetails(
          BankDetailsRequest(
            accountHolder: _accountHolderController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            bankName: _bankNameController.text.trim(),
            ifsc: _ifscController.text.trim(),
          ),
        );
        break;
      case 3:
        if (role == UserRole.farmer) {
          await onboarding.submitKycDetails(
            KycRequest(
              docType: _idType,
              docNo: _idNumberController.text.trim().toUpperCase(),
              frontImage: _idFront!,
              backImage: _idType == 'AADHAAR' ? _idBack : null,
            ),
          );
        } else {
          await onboarding.submitDeliveryKycDetails(
            DeliveryKycRequest(
              idType: _idType,
              idNumber: _idNumberController.text.trim().toUpperCase(),
              idFrontImage: _idFront!,
              idBackImage: _idType == 'AADHAAR' ? _idBack : null,
              drivingLicenseImage: _drivingLicense!,
              rcImage: _rcImage!,
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);
    final role = ref.watch(authControllerProvider).role;
    final step = _effectiveStep + 1;
    const totalSteps = 4;

    ref.listen(onboardingControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) =>
            _showError(error.toString().replaceFirst('Exception: ', '')),
      );
    });

    return AuthPageScaffold(
      bottomBar: AppButton(
        text: step == 4 ? 'onboarding.finish'.tr() : 'common.continue'.tr(),
        isLoading: onboardingState.isLoading,
        onPressed: _submitStep,
      ).animate().fadeIn(delay: 400.ms),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              AuthStepHeader(
                currentStep: step,
                totalSteps: totalSteps,
                title: role == UserRole.farmer
                    ? 'onboarding.farmer_title'.tr()
                    : 'onboarding.delivery_title'.tr(),
                subtitle: _getStepSubtitle(step, role),
              ),

              const SizedBox(height: 32),

              if (step == 2)
                _buildRoleSpecificStep(
                  role,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),
              if (step == 3)
                _buildBankStep()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideX(begin: 0.05, end: 0),
              if (step == 4)
                _buildKycStep(
                  role,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepSubtitle(int step, UserRole role) {
    return switch (step) {
      2 =>
        role == UserRole.farmer
            ? 'onboarding.farm_details_subtitle'.tr()
            : 'onboarding.vehicle_profile_subtitle'.tr(),
      3 => 'onboarding.bank_details_subtitle'.tr(),
      4 => 'onboarding.id_verification_title'.tr(),
      _ => '',
    };
  }

  Widget _buildRoleSpecificStep(UserRole role) {
    return AuthGlassCard(
      child: role == UserRole.farmer
          ? Column(
              children: [
                AuthTextField(
                  controller: _stateController,
                  label: 'onboarding.state'.tr(),
                  prefixIcon: Icons.map_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _districtController,
                  label: 'onboarding.district'.tr(),
                  hint: 'e.g. Nashik',
                  prefixIcon: Icons.location_city_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _villageController,
                  label: 'onboarding.village'.tr(),
                  hint: 'e.g. Malegaon',
                  prefixIcon: Icons.home_work_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _landController,
                  keyboardType: TextInputType.number,
                  label: 'onboarding.land_area'.tr(),
                  hint: 'e.g. 5',
                  prefixIcon: Icons.landscape_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  label: 'onboarding.pincode'.tr(),
                  hint: 'e.g. 422001',
                  prefixIcon: Icons.pin_drop_rounded,
                ),
              ],
            )
          : Column(
              children: [
                AppDropdown<String>(
                  label: 'onboarding.vehicle_type'.tr(),
                  value: _vehicleType,
                  prefixIcon: Icons.local_shipping_rounded,
                  items: _vehicleTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.tr()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _vehicleType = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _vehicleNumberController,
                  label: 'onboarding.vehicle_number'.tr(),
                  hint: 'e.g. MH-15-AB-1234',
                  prefixIcon: Icons.directions_car_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _licenseController,
                  label: 'onboarding.license_number'.tr(),
                  hint: 'e.g. DL-1234567890',
                  prefixIcon: Icons.badge_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  label: 'onboarding.capacity'.tr(),
                  hint: 'e.g. 500',
                  prefixIcon: Icons.scale_rounded,
                ),
              ],
            ),
    );
  }

  Widget _buildBankStep() {
    return AuthGlassCard(
      child: Column(
        children: [
          AuthTextField(
            controller: _accountHolderController,
            label: 'onboarding.acc_holder'.tr(),
            hint: 'e.g. Sachin Tadkale',
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            label: 'onboarding.acc_number'.tr(),
            hint: 'e.g. 1234567890',
            prefixIcon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            controller: _bankNameController,
            label: 'onboarding.bank_name'.tr(),
            hint: 'e.g. State Bank of India',
            prefixIcon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            controller: _ifscController,
            label: 'onboarding.ifsc'.tr(),
            hint: 'e.g. SBIN0012345',
            prefixIcon: Icons.password_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildKycStep(UserRole role) {
    final isDelivery = role == UserRole.deliveryPartner;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthGlassCard(
          padding: EdgeInsets.zero,
          child: KycDocumentCard(
            docType: _idType,
            typeDropdown: AppDropdown<String>(
              label: 'onboarding.doc_type'.tr(),
              value: _idType,
              prefixIcon: Icons.assignment_ind_rounded,
              items: [
                DropdownMenuItem(
                  value: 'AADHAAR',
                  child: Text('onboarding.doc_aadhaar'.tr()),
                ),
                DropdownMenuItem(
                  value: 'PAN',
                  child: Text('onboarding.doc_pan'.tr()),
                ),
              ],
              onChanged: (v) => setState(() => _idType = v!),
            ),
            numberController: _idNumberController,
            numberHint: _idType == 'AADHAAR' ? 'e.g. 1234 5678 9012' : 'e.g. ABCDE1234F',
            numberLabel: 'onboarding.doc_number'.tr(),
            frontImage: _idFront,
            backImage: _idBack,
            onPickFront: () => _pickFile((f) => _idFront = f),
            onPickBack: () => _pickFile((f) => _idBack = f),
            onRemoveFront: () => setState(() => _idFront = null),
            onRemoveBack: () => setState(() => _idBack = null),
            isBackRequired: _idType == 'AADHAAR',
          ),
        ),

        if (isDelivery) ...[
          const SizedBox(height: AppSpacing.lg),
          AuthGlassCard(
            padding: EdgeInsets.zero,
            child: KycDocumentCard(
              numberController: _licenseController,
              numberLabel: 'onboarding.license_number'.tr(),
              frontImage: _drivingLicense,
              onPickFront: () => _pickFile((f) => _drivingLicense = f),
              onPickBack: () {},
              onRemoveFront: () => setState(() => _drivingLicense = null),
              isBackRequired: false,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthGlassCard(
            padding: EdgeInsets.zero,
            child: KycDocumentCard(
              numberController: _vehicleNumberController,
              numberLabel: 'onboarding.vehicle_number'.tr(),
              frontImage: _rcImage,
              onPickFront: () => _pickFile((f) => _rcImage = f),
              onPickBack: () {},
              onRemoveFront: () => setState(() => _rcImage = null),
              isBackRequired: false,
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        AuthGlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'onboarding.confirm_docs'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _agreeTerms,
                activeTrackColor: theme.colorScheme.primary,
                onChanged: (v) => setState(() => _agreeTerms = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

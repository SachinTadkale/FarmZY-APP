import 'package:dio/dio.dart';
import 'package:farmzy/features/auth/data/model/bank_details_request.dart';
import 'package:farmzy/features/auth/data/model/farm_request.dart';
import 'package:farmzy/features/auth/data/model/kyc_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/register_flow_repository.dart';
import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum RegisterStepAction { advanced, completed }

final registerFlowControllerProvider =
    StateNotifierProvider<RegisterFlowController, AsyncValue<RegisterStepAction?>>(
      (ref) {
        final repository = ref.read(registerFlowRepositoryProvider);
        return RegisterFlowController(ref, repository);
      },
    );

class RegisterFlowController
    extends StateNotifier<AsyncValue<RegisterStepAction?>> {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$',
  );
  static final RegExp _aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final RegExp _bankAccountRegex = RegExp(r'^\d{9,18}$');
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  final Ref _ref;
  final RegisterFlowRepository _repository;

  RegisterFlowController(this._ref, this._repository)
      : super(const AsyncData(null));

  Future<void> submitCurrentStep() async {
    final registerState = _ref.read(registerProvider);
    state = const AsyncLoading();

    try {
      switch (registerState.currentStep) {
        case 0:
          await _submitBasicDetails(registerState);
          _ref.read(registerProvider.notifier).nextStep();
          state = const AsyncData(RegisterStepAction.advanced);
          break;
        case 1:
          await _submitFarmDetails(registerState);
          _ref.read(registerProvider.notifier).nextStep();
          state = const AsyncData(RegisterStepAction.advanced);
          break;
        case 2:
          await _submitBankDetails(registerState);
          _ref.read(registerProvider.notifier).nextStep();
          state = const AsyncData(RegisterStepAction.advanced);
          break;
        case 3:
          await _submitKycDetails(registerState);
          _ref.read(registerProvider.notifier).nextStep();
          state = const AsyncData(RegisterStepAction.completed);
          break;
        default:
          state = const AsyncData(null);
      }
    } on DioException catch (e, stackTrace) {
      _setErrorState(e, stackTrace);
    } catch (e, stackTrace) {
      state = AsyncError(Exception(e.toString().replaceFirst('Exception: ', '')), stackTrace);
    }
  }

  Future<void> _submitBasicDetails(RegisterState registerState) async {
    if (registerState.name.trim().isEmpty ||
        registerState.phone.trim().isEmpty ||
        registerState.email.trim().isEmpty ||
        registerState.address.trim().isEmpty ||
        registerState.password.trim().isEmpty ||
        registerState.confirmPassword.trim().isEmpty ||
        registerState.gender.trim().isEmpty) {
      throw Exception('Please complete all basic details.');
    }

    if (!_emailRegex.hasMatch(registerState.email.trim())) {
      throw Exception('Please enter a valid email address.');
    }

    if (!_phoneRegex.hasMatch(registerState.phone.trim())) {
      throw Exception('Please enter a valid 10-digit mobile number.');
    }

    if (!_passwordRegex.hasMatch(registerState.password.trim())) {
      throw Exception(
        'Password must include uppercase, lowercase, number, special character and 8+ characters.',
      );
    }

    if (registerState.password.trim() != registerState.confirmPassword.trim()) {
      throw Exception('Passwords do not match.');
    }

    final response = await _repository.register(
      RegisterRequest(
        name: registerState.name.trim(),
        email: registerState.email.trim(),
        phoneNo: registerState.phone.trim(),
        address: registerState.address.trim(),
        gender: registerState.gender.trim().toUpperCase(),
        password: registerState.password.trim(),
      ),
    );

    if (response.token.isEmpty) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Registration succeeded but onboarding token was not returned.',
      );
    }

    _ref.read(registerProvider.notifier).setOnboardingToken(response.token);
  }

  Future<void> _submitFarmDetails(RegisterState registerState) async {
    final token = _requireToken(registerState);
    if (registerState.stateName.trim().isEmpty ||
        registerState.district.trim().isEmpty ||
        registerState.village.trim().isEmpty ||
        registerState.pincode.trim().length != 6 ||
        registerState.landArea.trim().isEmpty) {
      throw Exception('Please enter valid farm details.');
    }

    if (double.tryParse(registerState.landArea.trim()) == null) {
      throw Exception('Land area must be a valid number.');
    }

    await _repository.addFarm(
      token: token,
      request: FarmRequest(
        state: registerState.stateName.trim(),
        district: registerState.district.trim(),
        village: registerState.village.trim(),
        pincode: registerState.pincode.trim(),
        landArea: double.tryParse(registerState.landArea.trim()),
      ),
    );
  }

  Future<void> _submitBankDetails(RegisterState registerState) async {
    final token = _requireToken(registerState);
    final normalizedAccountNumber = registerState.accountNumber.trim();
    final normalizedIfsc = registerState.ifsc.trim().toUpperCase();

    if (registerState.accountHolder.trim().isEmpty ||
        normalizedAccountNumber.isEmpty ||
        registerState.bankName.trim().isEmpty ||
        normalizedIfsc.isEmpty) {
      throw Exception('Please complete all bank details.');
    }

    if (normalizedAccountNumber !=
        registerState.confirmAccountNumber.trim()) {
      throw Exception('Account numbers do not match.');
    }

    if (!_bankAccountRegex.hasMatch(normalizedAccountNumber)) {
      throw Exception('Account number must be 9 to 18 digits.');
    }

    if (!_ifscRegex.hasMatch(normalizedIfsc)) {
      throw Exception('Please enter a valid IFSC code.');
    }

    await _repository.addBank(
      token: token,
      request: BankDetailsRequest(
        accountHolder: registerState.accountHolder.trim(),
        accountNumber: normalizedAccountNumber,
        bankName: registerState.bankName.trim(),
        ifsc: normalizedIfsc,
      ),
    );
  }

  Future<void> _submitKycDetails(RegisterState registerState) async {
    final token = _requireToken(registerState);
    if (registerState.idType.trim().isEmpty ||
        registerState.idNumber.trim().isEmpty ||
        registerState.frontImage == null ||
        !registerState.agreeTerms) {
      throw Exception('Please complete the KYC form and accept the terms.');
    }

    final normalizedIdNumber = registerState.idNumber.trim().toUpperCase();
    if (registerState.idType == 'AADHAR' &&
        !_aadhaarRegex.hasMatch(normalizedIdNumber)) {
      throw Exception('Aadhaar number must be 12 digits.');
    }

    if (registerState.idType == 'PAN' &&
        !_panRegex.hasMatch(normalizedIdNumber)) {
      throw Exception('Please enter a valid PAN number.');
    }

    if (registerState.idType == 'AADHAR' && registerState.backImage == null) {
      throw Exception('Please upload the back image for Aadhaar.');
    }

    await _repository.uploadKyc(
      token: token,
      request: KycRequest(
        docType: registerState.idType,
        docNo: normalizedIdNumber,
        frontImage: registerState.frontImage!,
        backImage: registerState.backImage,
      ),
    );
  }

  String _requireToken(RegisterState registerState) {
    if (registerState.onboardingToken.isEmpty) {
      throw Exception('Registration token missing. Please restart onboarding.');
    }
    return registerState.onboardingToken;
  }

  void _setErrorState(DioException e, StackTrace stackTrace) {
    final responseData = e.response?.data;
    final rawMessage =
        responseData is Map<String, dynamic>
            ? ((responseData['message'] ??
                        responseData['error'] ??
                        'Registration step failed.')
                    .toString())
            : (e.message ?? 'Registration step failed.');
    final message = switch (rawMessage) {
      'BANK_DETAILS_ENCRYPTION_KEY is not defined' =>
        'Bank details could not be saved because the server bank-encryption key is missing. Please configure the backend and try again.',
      String() when rawMessage.contains('BANK_DETAILS_ENCRYPTION_KEY') =>
        'Bank details could not be saved because bank encryption is not configured correctly on the server.',
      _ => rawMessage,
    };
    state = AsyncError(Exception(message), stackTrace);
  }
}

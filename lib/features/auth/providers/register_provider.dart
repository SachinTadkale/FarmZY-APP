import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class RegisterState {
  final int currentStep;

  // Basic details
  final String name;
  final String phone;
  final String email;
  final String address;
  final String password;
  final String confirmPassword;
  final String gender;

  // Farm details
  final String stateName;
  final String district;
  final String village;
  final String pincode;
  final String landArea;

  // Bank details
  final String accountHolder;
  final String accountNumber;
  final String confirmAccountNumber;
  final String bankName;
  final String ifsc;

  // KYC details
  final String idType;
  final String idNumber;
  final File? frontImage;
  final File? backImage;
  final bool agreeTerms;

  // This token is only for onboarding requests after registration succeeds.
  final String onboardingToken;

  const RegisterState({
    this.currentStep = 0,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.password = '',
    this.confirmPassword = '',
    this.gender = '',
    this.stateName = '',
    this.district = '',
    this.village = '',
    this.pincode = '',
    this.landArea = '',
    this.accountHolder = '',
    this.accountNumber = '',
    this.confirmAccountNumber = '',
    this.bankName = '',
    this.ifsc = '',
    this.idType = '',
    this.idNumber = '',
    this.frontImage,
    this.backImage,
    this.agreeTerms = false,
    this.onboardingToken = '',
  });

  RegisterState copyWith({
    int? currentStep,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? password,
    String? confirmPassword,
    String? gender,
    String? stateName,
    String? district,
    String? village,
    String? pincode,
    String? landArea,
    String? accountHolder,
    String? accountNumber,
    String? confirmAccountNumber,
    String? bankName,
    String? ifsc,
    String? idType,
    String? idNumber,
    File? frontImage,
    bool clearFrontImage = false,
    File? backImage,
    bool clearBackImage = false,
    bool? agreeTerms,
    String? onboardingToken,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      gender: gender ?? this.gender,
      stateName: stateName ?? this.stateName,
      district: district ?? this.district,
      village: village ?? this.village,
      pincode: pincode ?? this.pincode,
      landArea: landArea ?? this.landArea,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      bankName: bankName ?? this.bankName,
      ifsc: ifsc ?? this.ifsc,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      frontImage: clearFrontImage ? null : (frontImage ?? this.frontImage),
      backImage: clearBackImage ? null : (backImage ?? this.backImage),
      agreeTerms: agreeTerms ?? this.agreeTerms,
      onboardingToken: onboardingToken ?? this.onboardingToken,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updateBasicDetails({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? password,
    String? confirmPassword,
    String? gender,
  }) {
    state = state.copyWith(
      name: name,
      phone: phone,
      email: email,
      address: address,
      password: password,
      confirmPassword: confirmPassword,
      gender: gender,
    );
  }

  void updateFarmDetails({
    String? stateName,
    String? district,
    String? village,
    String? pincode,
    String? landArea,
  }) {
    state = state.copyWith(
      stateName: stateName,
      district: district,
      village: village,
      pincode: pincode,
      landArea: landArea,
    );
  }

  void updateBankDetails({
    String? accountHolder,
    String? accountNumber,
    String? confirmAccountNumber,
    String? bankName,
    String? ifsc,
  }) {
    state = state.copyWith(
      accountHolder: accountHolder,
      accountNumber: accountNumber,
      confirmAccountNumber: confirmAccountNumber,
      bankName: bankName,
      ifsc: ifsc,
    );
  }

  void updateVerificationDetails({
    String? idType,
    String? idNumber,
    File? frontImage,
    bool clearFrontImage = false,
    File? backImage,
    bool clearBackImage = false,
    bool? agreeTerms,
  }) {
    state = state.copyWith(
      idType: idType,
      idNumber: idNumber,
      frontImage: frontImage,
      clearFrontImage: clearFrontImage,
      backImage: backImage,
      clearBackImage: clearBackImage,
      agreeTerms: agreeTerms,
    );
  }

  void setOnboardingToken(String token) {
    state = state.copyWith(onboardingToken: token);
  }

  void reset() {
    state = const RegisterState();
  }
}

final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
      return RegisterNotifier();
    });

import 'package:flutter_riverpod/legacy.dart';

class RegisterState {
  final int currentStep;

  // Basic
  final String name;
  final String phone;
  final String email;
  final String password;
  final String gender;

  // Farm
  final String stateName;
  final String district;
  final String village;
  final String landArea;
  final String farmType;

  // Bank
  final String accountHolder;
  final String accountNumber;
  final String ifsc;

  // Verification
  final String idType;
  final String idNumber;

  const RegisterState({
    this.currentStep = 0,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.gender = '',
    this.stateName = '',
    this.district = '',
    this.village = '',
    this.landArea = '',
    this.farmType = '',
    this.accountHolder = '',
    this.accountNumber = '',
    this.ifsc = '',
    this.idType = '',
    this.idNumber = '',
  });

  RegisterState copyWith({
    int? currentStep,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? gender,
    String? stateName,
    String? district,
    String? village,
    String? landArea,
    String? pincode,
    String? farmType,
    String? accountHolder,
    String? accountNumber,
    String? ifsc,
    String? idType,
    String? idNumber,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      stateName: stateName ?? this.stateName,
      district: district ?? this.district,
      village: village ?? this.village,
      landArea: landArea ?? this.landArea,
      farmType: farmType ?? this.farmType,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      ifsc: ifsc ?? this.ifsc,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  // RegisterNotifier() : super(const RegisterState());
   RegisterNotifier() 
    : super(const RegisterState(currentStep: 1));
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

  void updateBasicDetails({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String gender,
  }) {
    state = state.copyWith(
      name: name,
      phone: phone,
      email: email,
      password: password,
      gender: gender,
    );
  }

  void reset() {
    state = const RegisterState();
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(),
);

/*
Multi-step

Temporary form state

UI-heavy

Not authenticated yet
*/

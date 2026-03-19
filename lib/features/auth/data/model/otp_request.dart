class OtpRequest {
  final String email;
  final String? otp;

  OtpRequest({required this.email, this.otp});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (otp != null) 'otp': otp,
    };
  }
}

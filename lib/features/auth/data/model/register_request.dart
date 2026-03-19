class RegisterRequest {
  final String name;
  final String email;
  final String phoneNo;
  final String address;
  final String gender;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.address,
    required this.gender,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_no': phoneNo,
      'address': address,
      'gender': gender,
      'password': password,
    };
  }
}

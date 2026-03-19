class BankDetailsRequest {
  final String accountHolder;
  final String accountNumber;
  final String bankName;
  final String ifsc;

  BankDetailsRequest({
    required this.accountHolder,
    required this.accountNumber,
    required this.bankName,
    required this.ifsc,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'ifsc': ifsc,
    };
  }
}

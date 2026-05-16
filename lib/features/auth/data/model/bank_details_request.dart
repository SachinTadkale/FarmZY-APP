/**
 * Module: Bank Details Request
 * Purpose: Implements the Bank Details Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
/**
 * Bank Details Request.
 */
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

/**
 * To Json.
 */
  Map<String, dynamic> toJson() {
    return {
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'ifsc': ifsc,
    };
  }
}

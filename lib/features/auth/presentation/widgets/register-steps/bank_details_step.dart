import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankDetailsStep extends ConsumerStatefulWidget {
  const BankDetailsStep({super.key});

  @override
  ConsumerState<BankDetailsStep> createState() => _BankDetailsStepState();
}

class _BankDetailsStepState extends ConsumerState<BankDetailsStep> {
  static const double _fieldRadius = 12;

  late final TextEditingController holderController;
  late final TextEditingController accountController;
  late final TextEditingController confirmAccountController;
  late final TextEditingController bankNameController;
  late final TextEditingController ifscController;

  final holderFocus = FocusNode();
  final accountFocus = FocusNode();
  final confirmAccountFocus = FocusNode();
  final bankNameFocus = FocusNode();
  final ifscFocus = FocusNode();

  bool obscureAccount = true;
  bool obscureConfirmAccount = true;

  @override
  void initState() {
    super.initState();
    final registerState = ref.read(registerProvider);
    holderController = TextEditingController(text: registerState.accountHolder);
    accountController = TextEditingController(text: registerState.accountNumber);
    confirmAccountController =
        TextEditingController(text: registerState.confirmAccountNumber);
    bankNameController = TextEditingController(text: registerState.bankName);
    ifscController = TextEditingController(text: registerState.ifsc);
  }

  @override
  void dispose() {
    holderController.dispose();
    accountController.dispose();
    confirmAccountController.dispose();
    bankNameController.dispose();
    ifscController.dispose();
    holderFocus.dispose();
    accountFocus.dispose();
    confirmAccountFocus.dispose();
    bankNameFocus.dispose();
    ifscFocus.dispose();
    super.dispose();
  }

  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  void _updateBank({
    String? accountHolder,
    String? accountNumber,
    String? confirmAccountNumber,
    String? bankName,
    String? ifsc,
  }) {
    ref.read(registerProvider.notifier).updateBankDetails(
          accountHolder: accountHolder,
          accountNumber: accountNumber,
          confirmAccountNumber: confirmAccountNumber,
          bankName: bankName,
          ifsc: ifsc,
        );
  }

  @override
  Widget build(BuildContext context) {
    final accountMismatch =
        confirmAccountController.text.isNotEmpty &&
        accountController.text.trim() != confirmAccountController.text.trim();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bank Details', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'These details are needed to receive payments from the platform.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: holderController,
          focusNode: holderFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(accountFocus),
          onChanged: (value) => _updateBank(accountHolder: value),
          decoration: InputDecoration(
            hintText: 'Account Holder Name',
            prefixIcon: Icon(Icons.person, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: accountController,
          focusNode: accountFocus,
          keyboardType: TextInputType.number,
          obscureText: obscureAccount,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(confirmAccountFocus),
          onChanged: (value) {
            _updateBank(accountNumber: value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Account Number',
            prefixIcon: Icon(Icons.account_balance, color: primary),
            suffixIcon: IconButton(
              icon: Icon(
                obscureAccount ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscureAccount = !obscureAccount;
                });
              },
            ),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmAccountController,
          focusNode: confirmAccountFocus,
          keyboardType: TextInputType.number,
          obscureText: obscureConfirmAccount,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(bankNameFocus),
          onChanged: (value) {
            _updateBank(confirmAccountNumber: value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Confirm Account Number',
            prefixIcon: Icon(Icons.account_balance, color: primary),
            errorText: accountMismatch ? 'Account numbers do not match.' : null,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirmAccount
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscureConfirmAccount = !obscureConfirmAccount;
                });
              },
            ),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: bankNameController,
          focusNode: bankNameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(ifscFocus),
          onChanged: (value) => _updateBank(bankName: value),
          decoration: InputDecoration(
            hintText: 'Bank Name',
            prefixIcon: Icon(Icons.account_balance_outlined, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: ifscController,
          focusNode: ifscFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => ifscFocus.unfocus(),
          onChanged: (value) => _updateBank(ifsc: value.toUpperCase()),
          decoration: InputDecoration(
            hintText: 'IFSC Code',
            prefixIcon: Icon(Icons.qr_code, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

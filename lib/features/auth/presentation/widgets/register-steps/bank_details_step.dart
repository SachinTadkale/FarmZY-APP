import 'package:farmzy/features/auth/providers/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankDetailsStep extends ConsumerStatefulWidget {
  const BankDetailsStep({super.key});

  @override
  ConsumerState<BankDetailsStep> createState() =>
      _BankDetailsStepState();
}

class _BankDetailsStepState
    extends ConsumerState<BankDetailsStep> {
  final holderFocus = FocusNode();
  final accountFocus = FocusNode();
  final confirmAccountFocus = FocusNode();
  final bankNameFocus = FocusNode();
  final ifscFocus = FocusNode();

  bool obscureAccount = true;
  bool obscureConfirmAccount = true;

  void nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  @override
  void dispose() {
    holderFocus.dispose();
    accountFocus.dispose();
    confirmAccountFocus.dispose();
    bankNameFocus.dispose();
    ifscFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bank Details",
          style: theme.textTheme.titleLarge,
        ),

        const SizedBox(height: 8),

        Text(
          "You can add bank details later to receive payments.",
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 20),

        /// 🔹 Account Holder Name
        TextFormField(
          focusNode: holderFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(accountFocus),
          decoration: InputDecoration(
            hintText: "Account Holder Name",
            prefixIcon:
                Icon(Icons.person, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// 🔹 Account Number (Hidden)
        TextFormField(
          focusNode: accountFocus,
          keyboardType: TextInputType.number,
          obscureText: obscureAccount,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) =>
              nextField(confirmAccountFocus),
          decoration: InputDecoration(
            hintText: "Account Number",
            prefixIcon: Icon(Icons.account_balance,
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

        /// 🔹 Confirm Account Number (Hidden)
        TextFormField(
          focusNode: confirmAccountFocus,
          keyboardType: TextInputType.number,
          obscureText: obscureConfirmAccount,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) =>
              nextField(bankNameFocus),
          decoration: InputDecoration(
            hintText: "Confirm Account Number",
            prefixIcon: Icon(Icons.account_balance,
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

        /// 🔹 Bank Name
        TextFormField(
          focusNode: bankNameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => nextField(ifscFocus),
          decoration: InputDecoration(
            hintText: "Bank Name",
            prefixIcon:
                Icon(Icons.account_balance_outlined,
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

        /// 🔹 IFSC Code
        TextFormField(
          focusNode: ifscFocus,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            ifscFocus.unfocus();
          },
          decoration: InputDecoration(
            hintText: "IFSC Code",
            prefixIcon:
                Icon(Icons.qr_code, color: primary),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
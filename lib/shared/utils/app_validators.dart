import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class AppValidators {
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }
    // Remove commas if any
    final cleanValue = value.replaceAll(',', '');
    final price = double.tryParse(cleanValue);
    
    if (price == null || price <= 0) {
      return 'validation.invalid_price'.tr();
    }
    
    // Maximum 10 million to prevent extreme overflows
    if (price > 10000000) {
      return 'validation.price_too_high'.tr();
    }
    return null;
  }

  static String? validateQuantity(String? value, {double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }
    final qty = double.tryParse(value);
    if (qty == null || qty <= 0) {
      return 'validation.invalid_quantity'.tr();
    }
    if (max != null && qty > max) {
      return 'validation.exceeds_stock'.tr(args: [max.toString()]);
    }
    // Prevent unrealistic quantities (e.g., 1 billion KG)
    if (qty > 1000000000) {
      return 'validation.quantity_too_high'.tr();
    }
    return null;
  }

  static String? validateMinOrder(String? value, double totalQty) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }
    final min = double.tryParse(value);
    if (min == null || min <= 0) {
      return 'validation.invalid_min_order'.tr();
    }
    if (min > totalQty) {
      return 'validation.min_order_exceeds_total'.tr();
    }
    return null;
  }

  /// Stricter numeric formatter to prevent ".." or "1.2.3" or symbols
  static List<TextInputFormatter> numericFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    _StrictNumericFormatter(),
  ];
}

class _StrictNumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Prevent multiple dots
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    // Prevent starting with dot
    if (text.startsWith('.')) {
      return oldValue;
    }

    // Limit to 2 decimal places (already handled by regex but as safety)
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        return oldValue;
      }
    }

    return newValue;
  }
}

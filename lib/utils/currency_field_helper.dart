import 'package:flutter/material.dart';
import 'app_currency.dart';

/// Helpers for money [TextEditingController]s when currency changes.
class CurrencyFieldHelper {
  static void convertController(
    TextEditingController controller,
    AppCurrency from,
    AppCurrency to,
  ) {
    final value = double.tryParse(controller.text.trim());
    if (value == null) return;
    controller.text = formatInput(to.convertFrom(value, from), to);
  }

  static String formatInput(double amount, AppCurrency currency) {
    if (currency == AppCurrency.usd) {
      final s = amount.toStringAsFixed(2);
      return s.endsWith('.00') ? amount.toStringAsFixed(0) : s;
    }
    return amount.round().toString();
  }

  static void applyDefault(
    TextEditingController controller,
    AppCurrency currency,
    String defaultKey,
  ) {
    controller.text = formatInput(currency.defaultAmount(defaultKey), currency);
  }

  /// Call from [State.build] when [AppCurrency] from provider changes.
  static void handleCurrencyChange({
    required AppCurrency? lastCurrency,
    required AppCurrency currentCurrency,
    required VoidCallback onConvert,
  }) {
    if (lastCurrency != null && lastCurrency != currentCurrency) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onConvert());
    }
  }
}

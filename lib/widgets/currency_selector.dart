import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_currency.dart';

/// IDR / USD toggle synced with [AppProvider].
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currency = provider.currency;

    return SegmentedButton<AppCurrency>(
      segments: [
        ButtonSegment(
          value: AppCurrency.idr,
          label: Text(provider.translate('Rp', 'Rp')),
          icon: const Icon(Icons.currency_exchange_rounded, size: 18),
        ),
        ButtonSegment(
          value: AppCurrency.usd,
          label: const Text('USD'),
          icon: const Icon(Icons.attach_money_rounded, size: 18),
        ),
      ],
      selected: {currency},
      onSelectionChanged: (selection) {
        provider.changeCurrency(selection.first);
      },
    );
  }
}

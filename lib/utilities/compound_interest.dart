import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_currency.dart';
import '../utils/currency_field_helper.dart';
import '../widgets/bento_card.dart';
import '../widgets/currency_selector.dart';

class CompoundInterestWidget extends StatefulWidget {
  const CompoundInterestWidget({super.key});

  @override
  State<CompoundInterestWidget> createState() => _CompoundInterestWidgetState();
}

class _CompoundInterestWidgetState extends State<CompoundInterestWidget> {
  AppCurrency? _lastCurrency;
  final _principalController = TextEditingController(text: '10000000');
  final _rateController = TextEditingController(text: '6');
  final _yearsController = TextEditingController(text: '5');
  int _compoundsPerYear = 12;

  @override
  void initState() {
    super.initState();
    for (final c in [_principalController, _rateController, _yearsController]) {
      c.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncToProviderCurrency());
  }

  void _syncToProviderCurrency() {
    if (!mounted) return;
    final currency = context.read<AppProvider>().currency;
    _lastCurrency = currency;
    CurrencyFieldHelper.applyDefault(
      _principalController,
      currency,
      'compound_principal',
    );
    setState(() {});
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  ({double amount, double interest}) _calculate() {
    final p = double.tryParse(_principalController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final years = double.tryParse(_yearsController.text) ?? 0;
    if (p <= 0 || years <= 0) return (amount: 0, interest: 0);

    final r = rate / 100;
    final n = _compoundsPerYear.toDouble();
    final amount = p * math.pow(1 + r / n, n * years);
    return (amount: amount, interest: amount - p);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = provider.currency;
    final result = _calculate();

    CurrencyFieldHelper.handleCurrencyChange(
      lastCurrency: _lastCurrency,
      currentCurrency: currency,
      onConvert: () {
        if (_lastCurrency != null) {
          CurrencyFieldHelper.convertController(
            _principalController,
            _lastCurrency!,
            currency,
          );
          setState(() {});
        }
      },
    );
    _lastCurrency = currency;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CurrencySelector(),
          const SizedBox(height: 12),
          BentoCard(
            child: Column(
              children: [
                _field(
                  currency.amountLabel(
                    provider.languageCode,
                    'Pokok',
                    'Principal',
                  ),
                  _principalController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Bunga tahunan (%)', 'Annual rate (%)'),
                  _rateController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Periode (tahun)', 'Period (years)'),
                  _yearsController,
                  isDark,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _compoundsPerYear,
                  decoration: InputDecoration(
                    labelText: provider.translate(
                      'Frekuensi kompon',
                      'Compounding frequency',
                    ),
                    filled: true,
                    fillColor: AppTheme.cardAltColor(isDark),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(provider.translate('Tahunan', 'Yearly')),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text(provider.translate('Triwulan', 'Quarterly')),
                    ),
                    DropdownMenuItem(
                      value: 12,
                      child: Text(provider.translate('Bulanan', 'Monthly')),
                    ),
                    DropdownMenuItem(
                      value: 365,
                      child: Text(provider.translate('Harian', 'Daily')),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _compoundsPerYear = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BentoCard(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            child: Column(
              children: [
                Text(
                  provider.translate('Nilai akhir', 'Final amount'),
                  style: TextStyle(color: AppTheme.textSecondary(isDark)),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.formatMoney(result.amount),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${provider.translate('Total bunga:', 'Total interest:')} ${provider.formatMoney(result.interest)}',
                  style: TextStyle(color: AppTheme.textSecondary(isDark)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, bool isDark) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.cardAltColor(isDark),
      ),
    );
  }
}

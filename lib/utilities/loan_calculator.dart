import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_currency.dart';
import '../utils/currency_field_helper.dart';
import '../widgets/bento_card.dart';
import '../widgets/currency_selector.dart';

class LoanCalculatorWidget extends StatefulWidget {
  const LoanCalculatorWidget({super.key});

  @override
  State<LoanCalculatorWidget> createState() => _LoanCalculatorWidgetState();
}

class _LoanCalculatorWidgetState extends State<LoanCalculatorWidget> {
  AppCurrency? _lastCurrency;
  final _principalController = TextEditingController(text: '100000000');
  final _rateController = TextEditingController(text: '8');
  final _monthsController = TextEditingController(text: '12');

  @override
  void initState() {
    super.initState();
    for (final c in [
      _principalController,
      _rateController,
      _monthsController,
    ]) {
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
      'loan_principal',
    );
    setState(() {});
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  double _monthlyPayment() {
    final p = double.tryParse(_principalController.text) ?? 0;
    final annualRate = double.tryParse(_rateController.text) ?? 0;
    final n = int.tryParse(_monthsController.text) ?? 1;
    if (p <= 0 || n <= 0) return 0;

    final r = annualRate / 100 / 12;
    if (r == 0) return p / n;

    final factor = math.pow(1 + r, n);
    return p * r * factor / (factor - 1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = provider.currency;

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

    final monthly = _monthlyPayment();
    final p = double.tryParse(_principalController.text) ?? 0;
    final n = int.tryParse(_monthsController.text) ?? 1;
    final total = monthly * n;
    final interest = total - p;

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
                    'Pinjaman',
                    'Loan amount',
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
                  provider.translate('Tenor (bulan)', 'Term (months)'),
                  _monthsController,
                  isDark,
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
                  provider.translate('Cicilan per bulan', 'Monthly payment'),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.formatMoney(monthly),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  child: _stat(
                    provider.translate('Total bayar', 'Total paid'),
                    provider.formatMoney(total),
                    isDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BentoCard(
                  child: _stat(
                    provider.translate('Total bunga', 'Total interest'),
                    provider.formatMoney(interest),
                    isDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary(isDark),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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

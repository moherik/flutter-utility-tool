import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_currency.dart';
import '../utils/currency_field_helper.dart';
import '../widgets/bento_card.dart';
import '../widgets/currency_selector.dart';

class FuelCalculatorWidget extends StatefulWidget {
  const FuelCalculatorWidget({super.key});

  @override
  State<FuelCalculatorWidget> createState() => _FuelCalculatorWidgetState();
}

class _FuelCalculatorWidgetState extends State<FuelCalculatorWidget> {
  AppCurrency? _lastCurrency;
  final _distanceController = TextEditingController(text: '100');
  final _consumptionController = TextEditingController(text: '12');
  final _priceController = TextEditingController(text: '10000');

  @override
  void initState() {
    super.initState();
    for (final c in [
      _distanceController,
      _consumptionController,
      _priceController,
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
      _priceController,
      currency,
      'fuel_price_per_l',
    );
    setState(() {});
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _consumptionController.dispose();
    _priceController.dispose();
    super.dispose();
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
            _priceController,
            _lastCurrency!,
            currency,
          );
          setState(() {});
        }
      },
    );
    _lastCurrency = currency;

    final distance = double.tryParse(_distanceController.text) ?? 0;
    final consumption = double.tryParse(_consumptionController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    final liters = consumption > 0 ? distance / consumption : 0.0;
    final totalCost = liters * price;
    final costPerKm = distance > 0 ? totalCost / distance : 0.0;

    final priceLabel = currency.amountLabel(
      provider.languageCode,
      'Harga per liter',
      'Price per liter',
    );

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
                  provider.translate('Jarak (km)', 'Distance (km)'),
                  _distanceController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Konsumsi (km/L)', 'Consumption (km/L)'),
                  _consumptionController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(priceLabel, _priceController, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  child: _stat(
                    provider.translate('Liter', 'Liters'),
                    '${liters.toStringAsFixed(2)} L',
                    isDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BentoCard(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  child: _stat(
                    provider.translate('Total biaya', 'Total cost'),
                    provider.formatMoney(totalCost),
                    isDark,
                    highlight: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BentoCard(
            child: _stat(
              provider.translate('Biaya per km', 'Cost per km'),
              provider.formatMoney(costPerKm),
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, bool isDark, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(isDark)),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 20 : 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(isDark),
          ),
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

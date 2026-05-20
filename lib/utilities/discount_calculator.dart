import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_currency.dart';
import '../utils/currency_field_helper.dart';
import '../widgets/bento_card.dart';
import '../widgets/currency_selector.dart';

class DiscountCalculatorWidget extends StatefulWidget {
  const DiscountCalculatorWidget({super.key});

  @override
  State<DiscountCalculatorWidget> createState() =>
      _DiscountCalculatorWidgetState();
}

class _DiscountCalculatorWidgetState extends State<DiscountCalculatorWidget> {
  AppCurrency? _lastCurrency;
  double _originalPrice = 100000;
  double _discountPercent = 10;
  double _taxPercent = 0;

  final TextEditingController _priceController = TextEditingController(
    text: '100000',
  );
  final TextEditingController _discountController = TextEditingController(
    text: '10',
  );
  final TextEditingController _taxController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_onChanged);
    _discountController.addListener(_onChanged);
    _taxController.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncToProviderCurrency());
  }

  void _syncToProviderCurrency() {
    if (!mounted) return;
    final currency = context.read<AppProvider>().currency;
    _lastCurrency = currency;
    CurrencyFieldHelper.applyDefault(
      _priceController,
      currency,
      'discount_price',
    );
    _onChanged();
  }

  void _onCurrencyConverted(AppCurrency from, AppCurrency to) {
    CurrencyFieldHelper.convertController(_priceController, from, to);
    _onChanged();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _originalPrice = double.tryParse(_priceController.text) ?? 0.0;
      _discountPercent = double.tryParse(_discountController.text) ?? 0.0;
      _taxPercent = double.tryParse(_taxController.text) ?? 0.0;
    });
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
          _onCurrencyConverted(_lastCurrency!, currency);
        }
      },
    );
    _lastCurrency = currency;

    final discountAmount = _originalPrice * (_discountPercent / 100);
    final priceAfterDiscount = _originalPrice - discountAmount;
    final taxAmount = priceAfterDiscount * (_taxPercent / 100);
    final finalPrice = priceAfterDiscount + taxAmount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CurrencySelector(),
          const SizedBox(height: 12),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(
                  label: currency.amountLabel(
                    provider.languageCode,
                    'Harga Asli',
                    'Original Price',
                  ),
                  controller: _priceController,
                  icon: Icons.payments_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: provider.translate('Diskon (%)', 'Discount (%)'),
                        controller: _discountController,
                        icon: Icons.percent_rounded,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: provider.translate('Pajak (%)', 'Tax (%)'),
                        controller: _taxController,
                        icon: Icons.receipt_long_rounded,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider.translate('Rincian Perhitungan', 'Calculation Summary'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          BentoCard(
            color: theme.primaryColor.withValues(alpha: 0.08),
            borderColor: theme.primaryColor,
            child: Column(
              children: [
                Text(
                  provider.translate('Harga Akhir', 'Final Price'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.formatMoney(finalPrice),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  child: Column(
                    children: [
                      Text(
                        provider.translate('Hemat', 'You Save'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.formatMoney(discountAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.tertiaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoCard(
                  child: Column(
                    children: [
                      Text(
                        provider.translate('Jumlah Pajak', 'Tax Amount'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.formatMoney(taxAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardAltColor(isDark),
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 20, color: theme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

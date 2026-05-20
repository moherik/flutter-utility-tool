import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class PercentageCalculatorWidget extends StatefulWidget {
  const PercentageCalculatorWidget({super.key});

  @override
  State<PercentageCalculatorWidget> createState() =>
      _PercentageCalculatorWidgetState();
}

class _PercentageCalculatorWidgetState extends State<PercentageCalculatorWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _aController = TextEditingController(text: '10');
  final _bController = TextEditingController(text: '200');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
    for (final c in [_aController, _bController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  double get _a => double.tryParse(_aController.text) ?? 0;
  double get _b => double.tryParse(_bController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String resultText;
    String resultLabel;
    switch (_tabController.index) {
      case 0:
        resultLabel = provider.translate(
          '$_a% dari $_b =',
          '$_a% of $_b =',
        );
        resultText = (_b * _a / 100).toStringAsFixed(2);
      case 1:
        resultLabel = provider.translate(
          '$_a adalah ...% dari $_b',
          '$_a is ...% of $_b',
        );
        resultText = _b == 0
            ? '—'
            : '${(_a / _b * 100).toStringAsFixed(2)}%';
      case 2:
        resultLabel = provider.translate(
          '$_b + $_a% =',
          '$_b + $_a% =',
        );
        resultText = (_b * (1 + _a / 100)).toStringAsFixed(2);
      default:
        resultLabel = '';
        resultText = '';
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            labelColor: theme.colorScheme.primary,
            tabs: [
              Tab(text: provider.translate('Dari', 'Of')),
              Tab(text: provider.translate('Persen', 'Percent')),
              Tab(text: provider.translate('Naik', 'Increase')),
            ],
          ),
          const SizedBox(height: 16),
          BentoCard(
            child: Column(
              children: [
                _field(
                  _tabController.index == 0
                      ? provider.translate('Persen (%)', 'Percent (%)')
                      : _tabController.index == 1
                      ? provider.translate('Nilai', 'Value')
                      : provider.translate('Tambah (%)', 'Add (%)'),
                  _aController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Angka', 'Number'),
                  _bController,
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
                  resultLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
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

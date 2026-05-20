import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class GcdLcmWidget extends StatefulWidget {
  const GcdLcmWidget({super.key});

  @override
  State<GcdLcmWidget> createState() => _GcdLcmWidgetState();
}

class _GcdLcmWidgetState extends State<GcdLcmWidget> {
  final _aController = TextEditingController(text: '48');
  final _bController = TextEditingController(text: '18');

  @override
  void initState() {
    super.initState();
    for (final c in [_aController, _bController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() * b.abs()) ~/ _gcd(a, b);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final a = int.tryParse(_aController.text);
    final b = int.tryParse(_bController.text);
    final valid = a != null && b != null && a > 0 && b > 0;
    final gcd = valid ? _gcd(a, b) : null;
    final lcm = valid ? _lcm(a, b) : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BentoCard(
            child: Column(
              children: [
                _field(
                  provider.translate('Angka A', 'Number A'),
                  _aController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Angka B', 'Number B'),
                  _bController,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!valid)
            BentoCard(
              child: Text(
                provider.translate(
                  'Masukkan dua bilangan bulat positif.',
                  'Enter two positive integers.',
                ),
                style: TextStyle(color: AppTheme.textSecondary(isDark)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: BentoCard(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    child: _result(
                      provider.translate('FPB / GCD', 'GCD'),
                      '$gcd',
                      isDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BentoCard(
                    child: _result(
                      provider.translate('KPK / LCM', 'LCM'),
                      '$lcm',
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

  Widget _result(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary(isDark))),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
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
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.cardAltColor(isDark),
      ),
    );
  }
}

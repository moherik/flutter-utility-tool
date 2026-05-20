import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class RomanNumeralsWidget extends StatefulWidget {
  const RomanNumeralsWidget({super.key});

  @override
  State<RomanNumeralsWidget> createState() => _RomanNumeralsWidgetState();
}

class _RomanNumeralsWidgetState extends State<RomanNumeralsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _numberController = TextEditingController(text: '2024');
  final _romanController = TextEditingController(text: 'MMXXIV');

  static const _values = [
    (1000, 'M'),
    (900, 'CM'),
    (500, 'D'),
    (400, 'CD'),
    (100, 'C'),
    (90, 'XC'),
    (50, 'L'),
    (40, 'XL'),
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
    _numberController.addListener(() => setState(() {}));
    _romanController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _numberController.dispose();
    _romanController.dispose();
    super.dispose();
  }

  String? _toRoman(int n) {
    if (n < 1 || n > 3999) return null;
    final buffer = StringBuffer();
    var remaining = n;
    for (final (value, symbol) in _values) {
      while (remaining >= value) {
        buffer.write(symbol);
        remaining -= value;
      }
    }
    return buffer.toString();
  }

  int? _fromRoman(String input) {
    final s = input.trim().toUpperCase();
    if (!RegExp(r'^[IVXLCDM]+$').hasMatch(s)) return null;

    const map = {
      'I': 1,
      'V': 5,
      'X': 10,
      'L': 50,
      'C': 100,
      'D': 500,
      'M': 1000,
    };

    var total = 0;
    var prev = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      final val = map[s[i]];
      if (val == null) return null;
      if (val < prev) {
        total -= val;
      } else {
        total += val;
        prev = val;
      }
    }

    return _toRoman(total) == s ? total : null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String output;
    String? error;
    if (_tabController.index == 0) {
      final n = int.tryParse(_numberController.text);
      if (n == null) {
        error = provider.translate('Angka tidak valid', 'Invalid number');
        output = '';
      } else {
        final roman = _toRoman(n);
        if (roman == null) {
          error = provider.translate(
            'Gunakan angka 1–3999',
            'Use numbers 1–3999',
          );
          output = '';
        } else {
          output = roman;
        }
      }
    } else {
      final n = _fromRoman(_romanController.text);
      if (n == null) {
        error = provider.translate(
          'Notasi Romawi tidak valid',
          'Invalid Roman notation',
        );
        output = '';
      } else {
        output = '$n';
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            tabs: [
              Tab(text: provider.translate('→ Romawi', '→ Roman')),
              Tab(text: provider.translate('← Angka', '← Number')),
            ],
          ),
          const SizedBox(height: 16),
          BentoCard(
            child: _tabController.index == 0
                ? TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: provider.translate('Angka', 'Number'),
                      filled: true,
                      fillColor: AppTheme.cardAltColor(isDark),
                    ),
                  )
                : TextField(
                    controller: _romanController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: provider.translate('Romawi', 'Roman'),
                      filled: true,
                      fillColor: AppTheme.cardAltColor(isDark),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null)
                  Text(error, style: TextStyle(color: AppTheme.statusDanger(isDark)))
                else ...[
                  Text(
                    provider.translate('Hasil', 'Result'),
                    style: TextStyle(color: AppTheme.textSecondary(isDark)),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    output,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: output.isEmpty
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: output));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.translate('Disalin', 'Copied'),
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

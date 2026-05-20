import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class RandomNumberWidget extends StatefulWidget {
  const RandomNumberWidget({super.key});

  @override
  State<RandomNumberWidget> createState() => _RandomNumberWidgetState();
}

class _RandomNumberWidgetState extends State<RandomNumberWidget> {
  final _minController = TextEditingController(text: '1');
  final _maxController = TextEditingController(text: '100');
  final _countController = TextEditingController(text: '1');
  final _random = Random();
  List<int> _results = [];

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _generate() {
    final min = int.tryParse(_minController.text) ?? 1;
    final max = int.tryParse(_maxController.text) ?? 100;
    final count = (int.tryParse(_countController.text) ?? 1).clamp(1, 50);

    if (min > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppProvider>().translate(
              'Nilai minimum harus ≤ maksimum',
              'Minimum must be ≤ maximum',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _results = List.generate(
        count,
        (_) => min + _random.nextInt(max - min + 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BentoCard(
            child: Column(
              children: [
                _field(
                  provider.translate('Minimum', 'Minimum'),
                  _minController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Maksimum', 'Maximum'),
                  _maxController,
                  isDark,
                ),
                const SizedBox(height: 12),
                _field(
                  provider.translate('Jumlah angka', 'How many numbers'),
                  _countController,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.shuffle_rounded),
            label: Text(provider.translate('Acak', 'Generate')),
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 16),
            BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.translate('Hasil', 'Results'),
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: provider.translate('Salin', 'Copy'),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _results.join(', ')),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.translate('Disalin', 'Copied'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _results.map((n) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.controlRadius,
                          ),
                        ),
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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

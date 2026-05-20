import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class ColorConverterWidget extends StatefulWidget {
  const ColorConverterWidget({super.key});

  @override
  State<ColorConverterWidget> createState() => _ColorConverterWidgetState();
}

class _ColorConverterWidgetState extends State<ColorConverterWidget> {
  final _hexController = TextEditingController(text: '6366F1');

  Color get _color {
    var hex = _hexController.text.trim().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return AppTheme.primaryColor;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return AppTheme.primaryColor;
    return Color(value);
  }

  @override
  void initState() {
    super.initState();
    _hexController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final c = _color;
    final r = c.r * 255;
    final g = c.g * 255;
    final b = c.b * 255;
    final hex = '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BentoCard(
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                    border: Border.all(color: AppTheme.borderColor(isDark)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hexController,
                  decoration: InputDecoration(
                    labelText: provider.translate('Kode HEX', 'HEX code'),
                    prefixText: '#',
                    filled: true,
                    fillColor: AppTheme.cardAltColor(isDark),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                    LengthLimitingTextInputFormatter(8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BentoCard(
            child: Column(
              children: [
                _row('HEX', hex, provider, isDark),
                const Divider(height: 20),
                _row('RGB', '${r.round()}, ${g.round()}, ${b.round()}', provider, isDark),
                const Divider(height: 20),
                _row(
                  'Flutter',
                  'Color(0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})',
                  provider,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, AppProvider provider, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary(isDark),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(isDark),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.translate('Disalin', 'Copied'))),
            );
          },
        ),
      ],
    );
  }
}

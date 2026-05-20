import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class UuidGeneratorWidget extends StatefulWidget {
  const UuidGeneratorWidget({super.key});

  @override
  State<UuidGeneratorWidget> createState() => _UuidGeneratorWidgetState();
}

class _UuidGeneratorWidgetState extends State<UuidGeneratorWidget> {
  final _random = Random.secure();
  String? _current;
  final List<String> _history = [];

  String _generateV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}-'
        '${hex(bytes[4])}${hex(bytes[5])}-'
        '${hex(bytes[6])}${hex(bytes[7])}-'
        '${hex(bytes[8])}${hex(bytes[9])}-'
        '${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }

  void _generate() {
    setState(() {
      _current = _generateV4();
      _history.remove(_current);
      _history.insert(0, _current!);
      if (_history.length > 5) _history.removeLast();
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
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(provider.translate('Buat UUID', 'Generate UUID')),
          ),
          if (_current != null) ...[
            const SizedBox(height: 16),
            BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(
                    _current!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _current!));
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
              ),
            ),
          ],
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              provider.translate('Riwayat', 'History'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._history.map(
              (uuid) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BentoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    uuid,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(isDark),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

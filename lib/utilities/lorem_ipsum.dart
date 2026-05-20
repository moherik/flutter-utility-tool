import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class LoremIpsumWidget extends StatefulWidget {
  const LoremIpsumWidget({super.key});

  @override
  State<LoremIpsumWidget> createState() => _LoremIpsumWidgetState();
}

class _LoremIpsumWidgetState extends State<LoremIpsumWidget> {
  final _random = Random();
  int _paragraphs = 3;
  String _output = '';

  static const _sentences = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.',
    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.',
    'Nulla facilisi morbi tempus iaculis urna id volutpat lacus laoreet.',
    'Pellentesque habitant morbi tristique senectus et netus et malesuada.',
    'Vivamus arcu felis bibendum ut tristique et egestas quis ipsum.',
  ];

  void _generate() {
    final buffer = StringBuffer();
    for (var p = 0; p < _paragraphs; p++) {
      final count = 3 + _random.nextInt(4);
      for (var s = 0; s < count; s++) {
        buffer.write(_sentences[_random.nextInt(_sentences.length)]);
        if (s < count - 1) buffer.write(' ');
      }
      if (p < _paragraphs - 1) buffer.writeln('\n');
    }
    setState(() => _output = buffer.toString());
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.translate(
                    'Paragraf: $_paragraphs',
                    'Paragraphs: $_paragraphs',
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                Slider(
                  value: _paragraphs.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_paragraphs',
                  onChanged: (v) => setState(() => _paragraphs = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(provider.translate('Generate', 'Generate')),
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            BentoCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.translate('Hasil', 'Output'),
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _output));
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
                  SelectableText(
                    _output,
                    style: TextStyle(
                      height: 1.5,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

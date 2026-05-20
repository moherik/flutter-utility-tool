import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class JsonFormatterWidget extends StatefulWidget {
  const JsonFormatterWidget({super.key});

  @override
  State<JsonFormatterWidget> createState() => _JsonFormatterWidgetState();
}

class _JsonFormatterWidgetState extends State<JsonFormatterWidget> {
  final _controller = TextEditingController(text: '{"name":"UtilityTool","version":1}');
  bool _pretty = true;
  String _output = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_format);
    _format();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _format() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _output = '';
        _error = null;
      });
      return;
    }
    try {
      final decoded = jsonDecode(text);
      final encoder = _pretty
          ? const JsonEncoder.withIndent('  ')
          : const JsonEncoder();
      setState(() {
        _output = encoder.convert(decoded);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _output = '';
        _error = e.toString();
      });
    }
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
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(provider.translate('Rapi', 'Pretty')),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(provider.translate('Minify', 'Minify')),
                    ),
                  ],
                  selected: {_pretty},
                  onSelectionChanged: (s) {
                    setState(() => _pretty = s.first);
                    _format();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BentoCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: provider.translate('Tempel JSON…', 'Paste JSON…'),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppTheme.textPrimary(isDark),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            BentoCard(
              child: Text(
                _error!,
                style: TextStyle(color: AppTheme.statusDanger(isDark)),
              ),
            )
          else if (_output.isNotEmpty)
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
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                      color: AppTheme.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

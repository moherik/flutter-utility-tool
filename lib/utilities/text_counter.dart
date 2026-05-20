import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class TextCounterWidget extends StatefulWidget {
  const TextCounterWidget({super.key});

  @override
  State<TextCounterWidget> createState() => _TextCounterWidgetState();
}

class _TextCounterWidgetState extends State<TextCounterWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  int _paragraphCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = _controller.text;

    final stats = [
      (
        provider.translate('Karakter', 'Characters'),
        '${text.length}',
      ),
      (
        provider.translate('Tanpa spasi', 'Without spaces'),
        '${text.replaceAll(RegExp(r'\s'), '').length}',
      ),
      (
        provider.translate('Kata', 'Words'),
        '${_wordCount(text)}',
      ),
      (
        provider.translate('Baris', 'Lines'),
        text.isEmpty ? '0' : '${text.split('\n').length}',
      ),
      (
        provider.translate('Paragraf', 'Paragraphs'),
        '${_paragraphCount(text)}',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BentoCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: provider.translate(
                  'Ketik atau tempel teks…',
                  'Type or paste text…',
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppTheme.textPrimary(isDark),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        BentoCard(
          child: Column(
            children: stats.map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.$1,
                      style: TextStyle(color: AppTheme.textSecondary(isDark)),
                    ),
                    Text(
                      s.$2,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

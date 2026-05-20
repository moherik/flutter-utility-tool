import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class TextConverterWidget extends StatefulWidget {
  const TextConverterWidget({super.key});

  @override
  State<TextConverterWidget> createState() => _TextConverterWidgetState();
}

class _TextConverterWidgetState extends State<TextConverterWidget> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  String _selectedOp = 'UPPERCASE';

  final List<String> _operations = [
    'UPPERCASE',
    'lowercase',
    'Title Case',
    'Base64 Encode',
    'Base64 Decode',
    'URL Encode',
    'URL Decode',
    'Binary Converter',
    'MD5 Hash',
    'SHA-256 Hash',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_processText);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _processText() {
    final text = _inputController.text;
    if (text.isEmpty) {
      setState(() {
        _output = '';
      });
      return;
    }

    try {
      switch (_selectedOp) {
        case 'UPPERCASE':
          _output = text.toUpperCase();
          break;
        case 'lowercase':
          _output = text.toLowerCase();
          break;
        case 'Title Case':
          _output = _toTitleCase(text);
          break;
        case 'Base64 Encode':
          _output = base64.encode(utf8.encode(text));
          break;
        case 'Base64 Decode':
          try {
            _output = utf8.decode(base64.decode(text));
          } catch (_) {
            _output = 'Invalid Base64 string';
          }
          break;
        case 'URL Encode':
          _output = Uri.encodeComponent(text);
          break;
        case 'URL Decode':
          try {
            _output = Uri.decodeComponent(text);
          } catch (_) {
            _output = 'Invalid URL encoded string';
          }
          break;
        case 'Binary Converter':
          _output = text.codeUnits
              .map((u) => u.toRadixString(2).padLeft(8, '0'))
              .join(' ');
          break;
        case 'MD5 Hash':
          _output = md5.convert(utf8.encode(text)).toString();
          break;
        case 'SHA-256 Hash':
          _output = sha256.convert(utf8.encode(text)).toString();
          break;
      }
    } catch (e) {
      _output = 'Error executing operation';
    }
    setState(() {});
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final charCount = _inputController.text.length;
    final wordCount = _inputController.text.trim().isEmpty
        ? 0
        : _inputController.text.trim().split(RegExp(r'\s+')).length;
    final lineCount = _inputController.text.isEmpty
        ? 0
        : '\n'.allMatches(_inputController.text).length + 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Card
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Teks Input', 'Input Text'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => _inputController.clear(),
                    ),
                  ],
                ),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: provider.translate(
                      'Ketik teks di sini...',
                      'Type text here...',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const Divider(height: 20),

                // Real-time Counts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountBlock(
                      charCount,
                      provider.translate('Karakter', 'Characters'),
                    ),
                    _buildCountBlock(
                      wordCount,
                      provider.translate('Kata', 'Words'),
                    ),
                    _buildCountBlock(
                      lineCount,
                      provider.translate('Baris', 'Lines'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Operation Selector Card
          BentoCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.translate('Pilih Operasi', 'Select Operation'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOp,
                    items: _operations.map((op) {
                      return DropdownMenuItem<String>(
                        value: op,
                        child: Text(op, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedOp = val;
                        });
                        _processText();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Output Card
          BentoCard(
            color: AppTheme.cardAltColor(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Teks Output', 'Output Text'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: _output.isEmpty
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: _output));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.translate(
                                      'Output disalin!',
                                      'Output copied!',
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SelectableText(
                  _output.isEmpty
                      ? provider.translate(
                          'Hasil konversi akan tampil di sini...',
                          'Conversion output will appear here...',
                        )
                      : _output,
                  style: TextStyle(
                    fontSize: 15,
                    color: _output.isEmpty
                        ? Colors.grey
                        : (isDark ? Colors.white : Colors.black87),
                    fontFamily:
                        [
                          'Base64 Encode',
                          'Base64 Decode',
                          'Binary Converter',
                          'MD5 Hash',
                          'SHA-256 Hash',
                        ].contains(_selectedOp)
                        ? 'monospace'
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBlock(int count, String label) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

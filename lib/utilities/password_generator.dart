import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class PasswordGeneratorWidget extends StatefulWidget {
  const PasswordGeneratorWidget({Key? key}) : super(key: key);

  @override
  State<PasswordGeneratorWidget> createState() =>
      _PasswordGeneratorWidgetState();
}

class _PasswordGeneratorWidgetState extends State<PasswordGeneratorWidget> {
  int _length = 12;
  bool _includeUpper = true;
  bool _includeLower = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String allowedChars = '';
    if (_includeUpper) allowedChars += upper;
    if (_includeLower) allowedChars += lower;
    if (_includeNumbers) allowedChars += numbers;
    if (_includeSymbols) allowedChars += symbols;

    if (allowedChars.isEmpty) {
      setState(() {
        _generatedPassword = '';
      });
      return;
    }

    final random = Random.secure();
    String password = '';

    // Ensure at least one character of each selected type is included
    final List<String> requiredChars = [];
    if (_includeUpper) requiredChars.add(upper[random.nextInt(upper.length)]);
    if (_includeLower) requiredChars.add(lower[random.nextInt(lower.length)]);
    if (_includeNumbers)
      requiredChars.add(numbers[random.nextInt(numbers.length)]);
    if (_includeSymbols)
      requiredChars.add(symbols[random.nextInt(symbols.length)]);

    for (int i = 0; i < _length - requiredChars.length; i++) {
      password += allowedChars[random.nextInt(allowedChars.length)];
    }

    // Insert required characters at random positions
    for (var char in requiredChars) {
      final pos = random.nextInt(password.length + 1);
      password = password.substring(0, pos) + char + password.substring(pos);
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  // Evaluate Password Strength
  Map<String, dynamic> _getStrength() {
    if (_generatedPassword.isEmpty)
      return {'text': '', 'color': Colors.grey, 'progress': 0.0};

    int score = 0;
    if (_generatedPassword.length >= 8) score++;
    if (_generatedPassword.length >= 14) score++;
    if (_includeUpper) score++;
    if (_includeLower) score++;
    if (_includeNumbers) score++;
    if (_includeSymbols) score++;

    if (score <= 2) {
      return {'text': 'Sangat Lemah', 'color': Colors.red, 'progress': 0.25};
    } else if (score <= 4) {
      return {'text': 'Sedang', 'color': Colors.orange, 'progress': 0.5};
    } else if (score <= 5) {
      return {'text': 'Kuat', 'color': Colors.blue, 'progress': 0.75};
    } else {
      return {'text': 'Sangat Aman', 'color': Colors.green, 'progress': 1.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strength = _getStrength();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Generated Output Card
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _generatedPassword.isEmpty
                          ? provider.translate(
                              'Pilih kriteria di bawah',
                              'Select options below',
                            )
                          : _generatedPassword,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: _generatedPassword.isEmpty
                        ? null
                        : () {
                            Clipboard.setData(
                              ClipboardData(text: _generatedPassword),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.translate(
                                    'Sandi disalin ke papan klip!',
                                    'Password copied to clipboard!',
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: _generatedPassword.isEmpty
                        ? null
                        : () {
                            Share.share(_generatedPassword);
                          },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Password strength bar
              if (_generatedPassword.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Kekuatan:', 'Strength:'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      provider.translate(strength['text'], strength['text']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: strength['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength['progress'],
                    color: strength['color'],
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Settings Card
        Expanded(
          child: BentoCard(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Length
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.translate(
                          'Panjang Karakter',
                          'Character Length',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$_length",
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _length.toDouble(),
                    min: 4,
                    max: 32,
                    divisions: 28,
                    activeColor: theme.primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _length = val.round();
                      });
                      _generatePassword();
                    },
                  ),
                  const Divider(height: 24),

                  // Toggles
                  _buildToggleRow(
                    title: provider.translate(
                      'Huruf Besar (A-Z)',
                      'Uppercase (A-Z)',
                    ),
                    value: _includeUpper,
                    onChanged: (val) {
                      setState(() => _includeUpper = val);
                      _generatePassword();
                    },
                    theme: theme,
                  ),
                  _buildToggleRow(
                    title: provider.translate(
                      'Huruf Kecil (a-z)',
                      'Lowercase (a-z)',
                    ),
                    value: _includeLower,
                    onChanged: (val) {
                      setState(() => _includeLower = val);
                      _generatePassword();
                    },
                    theme: theme,
                  ),
                  _buildToggleRow(
                    title: provider.translate('Angka (0-9)', 'Numbers (0-9)'),
                    value: _includeNumbers,
                    onChanged: (val) {
                      setState(() => _includeNumbers = val);
                      _generatePassword();
                    },
                    theme: theme,
                  ),
                  _buildToggleRow(
                    title: provider.translate(
                      'Simbol (!@#...)',
                      'Symbols (!@#...)',
                    ),
                    value: _includeSymbols,
                    onChanged: (val) {
                      setState(() => _includeSymbols = val);
                      _generatePassword();
                    },
                    theme: theme,
                  ),

                  const SizedBox(height: 24),

                  // Regenerate Button
                  ElevatedButton.icon(
                    onPressed: _generatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(provider.translate('BUAT ULANG', 'REGENERATE')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          Switch(
            value: value,
            activeColor: theme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

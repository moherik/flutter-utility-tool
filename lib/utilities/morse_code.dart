import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class MorseCodeWidget extends StatefulWidget {
  const MorseCodeWidget({Key? key}) : super(key: key);

  @override
  State<MorseCodeWidget> createState() => _MorseCodeWidgetState();
}

class _MorseCodeWidgetState extends State<MorseCodeWidget> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _morseController = TextEditingController();
  bool _isPlaying = false;
  bool _flashState = false;

  static const Map<String, String> _textToMorseMap = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    ' ': '/',
  };

  static final Map<String, String> _morseToTextMap = _textToMorseMap.map(
    (key, value) => MapEntry(value, key),
  );

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _morseController.addListener(_onMorseChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _morseController.dispose();
    super.dispose();
  }

  bool _internalChange = false;

  void _onTextChanged() {
    if (_internalChange) return;
    _internalChange = true;

    final text = _textController.text.toUpperCase();
    final morseChars = text.split('').map((char) {
      return _textToMorseMap[char] ?? '';
    });
    _morseController.text = morseChars.join(' ');

    _internalChange = false;
  }

  void _onMorseChanged() {
    if (_internalChange) return;
    _internalChange = true;

    final morse = _morseController.text;
    final words = morse.split('   '); // 3 spaces for word separator
    final textWords = words.map((word) {
      final letters = word.split(' ');
      return letters.map((letter) => _morseToTextMap[letter] ?? '').join('');
    });
    _textController.text = textWords.join(' ');

    _internalChange = false;
  }

  // Play Morse via visual screen flashing
  Future<void> _playMorse() async {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
    });

    final morseStr = _morseController.text;
    for (int i = 0; i < morseStr.length; i++) {
      if (!_isPlaying) break;
      final char = morseStr[i];

      if (char == '.') {
        setState(() => _flashState = true);
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() => _flashState = false);
        await Future.delayed(const Duration(milliseconds: 200));
      } else if (char == '-') {
        setState(() => _flashState = true);
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() => _flashState = false);
        await Future.delayed(const Duration(milliseconds: 200));
      } else if (char == ' ') {
        await Future.delayed(const Duration(milliseconds: 400));
      } else if (char == '/') {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    setState(() {
      _isPlaying = false;
      _flashState = false;
    });
  }

  void _stopMorse() {
    setState(() {
      _isPlaying = false;
      _flashState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_flashState) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: _stopMorse,
          child: const Center(
            child: Text(
              'FLASHING MORSE CODE...',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text Input Card
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Teks Normal', 'Plain Text'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _textController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.translate(
                                'Teks disalin!',
                                'Text copied!',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: provider.translate(
                      'Masukkan teks...',
                      'Enter text...',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Morse Input/Output Card
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Kode Morse', 'Morse Code'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _morseController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.translate(
                                'Kode morse disalin!',
                                'Morse code copied!',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _morseController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: provider.translate(
                      'Masukkan morse (. atau -)...',
                      'Enter morse (. or -)...',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          BentoCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPlaying ? _stopMorse : _playMorse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying
                        ? Colors.red
                        : theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _isPlaying
                        ? 'STOP'
                        : provider.translate('PUTAR VISUAL', 'PLAY VISUAL'),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    _textController.clear();
                    _morseController.clear();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: const Icon(Icons.clear_all_rounded),
                  label: Text(provider.translate('HAPUS SEMUA', 'CLEAR ALL')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class NumberToWordsWidget extends StatefulWidget {
  const NumberToWordsWidget({super.key});

  @override
  State<NumberToWordsWidget> createState() => _NumberToWordsWidgetState();
}

class _NumberToWordsWidgetState extends State<NumberToWordsWidget> {
  final _controller = TextEditingController(text: '12345');

  String _words(String lang) {
    final raw = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return '';
    if (raw.length > 15) {
      return lang == 'id'
          ? 'Angka terlalu besar (maks. 15 digit)'
          : 'Number too large (max 15 digits)';
    }
    final n = BigInt.tryParse(raw);
    if (n == null) return '';
    return lang == 'id'
        ? _NumberWords.id(n)
        : _NumberWords.en(n);
  }

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final words = _words(provider.languageCode);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BentoCard(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: provider.translate('Masukkan angka', 'Enter number'),
                filled: true,
                fillColor: AppTheme.cardAltColor(isDark),
              ),
            ),
          ),
          if (words.isNotEmpty) ...[
            const SizedBox(height: 16),
            BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.translate('Terbilang', 'In words'),
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: words));
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
                  Text(
                    words,
                    style: TextStyle(
                      fontSize: 16,
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

class _NumberWords {
  static String en(BigInt n) {
    if (n == BigInt.zero) return 'zero';
    if (n < BigInt.zero) return 'minus ${_chunkEn(-n)}';
    return _chunkEn(n).trim();
  }

  static String _chunkEn(BigInt n) {
    if (n >= BigInt.from(1000000000000)) {
      return '${_chunkEn(n ~/ BigInt.from(1000000000000))} trillion ${_chunkEn(n % BigInt.from(1000000000000))}';
    }
    if (n >= BigInt.from(1000000000)) {
      return '${_chunkEn(n ~/ BigInt.from(1000000000))} billion ${_chunkEn(n % BigInt.from(1000000000))}';
    }
    if (n >= BigInt.from(1000000)) {
      return '${_chunkEn(n ~/ BigInt.from(1000000))} million ${_chunkEn(n % BigInt.from(1000000))}';
    }
    if (n >= BigInt.from(1000)) {
      return '${_chunkEn(n ~/ BigInt.from(1000))} thousand ${_chunkEn(n % BigInt.from(1000))}';
    }
    if (n >= BigInt.from(100)) {
      return '${_onesEn((n ~/ BigInt.from(100)).toInt())} hundred ${_chunkEn(n % BigInt.from(100))}';
    }
    if (n >= BigInt.from(20)) {
      const tens = [
        '', '', 'twenty', 'thirty', 'forty', 'fifty',
        'sixty', 'seventy', 'eighty', 'ninety',
      ];
      return '${tens[(n ~/ BigInt.from(10)).toInt()]} ${_onesEn((n % BigInt.from(10)).toInt())}';
    }
    if (n >= BigInt.from(10)) {
      const teens = [
        'ten', 'eleven', 'twelve', 'thirteen', 'fourteen',
        'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen',
      ];
      return teens[(n - BigInt.from(10)).toInt()];
    }
    return _onesEn(n.toInt());
  }

  static String _onesEn(int n) {
    const w = [
      '', 'one', 'two', 'three', 'four', 'five',
      'six', 'seven', 'eight', 'nine',
    ];
    return n == 0 ? '' : w[n];
  }

  static String id(BigInt n) {
    if (n == BigInt.zero) return 'nol';
    if (n < BigInt.zero) return 'minus ${_chunkId(-n)}';
    return _chunkId(n).trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _chunkId(BigInt n) {
    if (n >= BigInt.from(1000000000000)) {
      return '${_chunkId(n ~/ BigInt.from(1000000000000))} triliun ${_chunkId(n % BigInt.from(1000000000000))}';
    }
    if (n >= BigInt.from(1000000000)) {
      return '${_chunkId(n ~/ BigInt.from(1000000000))} miliar ${_chunkId(n % BigInt.from(1000000000))}';
    }
    if (n >= BigInt.from(1000000)) {
      return '${_chunkId(n ~/ BigInt.from(1000000))} juta ${_chunkId(n % BigInt.from(1000000))}';
    }
    if (n >= BigInt.from(1000)) {
      final t = n ~/ BigInt.from(1000);
      final rest = n % BigInt.from(1000);
      final head = t == BigInt.one ? 'seribu' : '${_chunkId(t)} ribu';
      return rest == BigInt.zero ? head : '$head ${_chunkId(rest)}';
    }
    if (n >= BigInt.from(100)) {
      final h = (n ~/ BigInt.from(100)).toInt();
      final rest = n % BigInt.from(100);
      final head = h == 1 ? 'seratus' : '${_onesId(h)} ratus';
      return rest == BigInt.zero ? head : '$head ${_chunkId(rest)}';
    }
    if (n >= BigInt.from(10)) {
      final t = (n ~/ BigInt.from(10)).toInt();
      final o = (n % BigInt.from(10)).toInt();
      if (t == 1) {
        const belas = [
          'sepuluh', 'sebelas', 'dua belas', 'tiga belas', 'empat belas',
          'lima belas', 'enam belas', 'tujuh belas', 'delapan belas', 'sembilan belas',
        ];
        return belas[o];
      }
      const puluh = [
        '', '', 'dua puluh', 'tiga puluh', 'empat puluh', 'lima puluh',
        'enam puluh', 'tujuh puluh', 'delapan puluh', 'sembilan puluh',
      ];
      return o == 0 ? puluh[t] : '${puluh[t]} ${_onesId(o)}';
    }
    return _onesId(n.toInt());
  }

  static String _onesId(int n) {
    const w = [
      '', 'satu', 'dua', 'tiga', 'empat', 'lima',
      'enam', 'tujuh', 'delapan', 'sembilan',
    ];
    return n == 0 ? '' : w[n];
  }
}

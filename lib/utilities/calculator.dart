import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({Key? key}) : super(key: key);

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _expression = '';
  String _result = '0';
  bool _scientific = false;

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _evaluate();
        if (_result != 'Error' && _expression.isNotEmpty) {
          context.read<AppProvider>().addCalcHistory(_expression, _result);
        }
      } else if (value == 'sin' ||
          value == 'cos' ||
          value == 'tan' ||
          value == 'ln' ||
          value == 'log' ||
          value == '√') {
        _expression += '$value(';
      } else {
        _expression += value;
      }

      // Real-time output estimation if expression is not empty and doesn't end with operator
      if (_expression.isNotEmpty && value != '=') {
        _estimateRealtime();
      }
    });
  }

  void _evaluate() {
    try {
      final res = _parseAndEvaluate(_expression);
      if (res.isNaN || res.isInfinite) {
        _result = 'Error';
      } else {
        _result = _formatResult(res);
      }
    } catch (e) {
      _result = 'Error';
    }
  }

  void _estimateRealtime() {
    try {
      String cleanExpr = _expression;
      // Auto-close open parentheses for parsing
      int openParen = '('.allMatches(cleanExpr).length;
      int closeParen = ')'.allMatches(cleanExpr).length;
      if (openParen > closeParen) {
        cleanExpr += ')' * (openParen - closeParen);
      }

      final res = _parseAndEvaluate(cleanExpr);
      if (!res.isNaN && !res.isInfinite) {
        _result = _formatResult(res);
      }
    } catch (_) {}
  }

  String _formatResult(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    String s = val.toString();
    if (s.length > 12) {
      s = val.toStringAsPrecision(10);
    }
    // Remove trailing zeros in decimals
    if (s.contains('.')) {
      while (s.endsWith('0')) {
        s = s.substring(0, s.length - 1);
      }
      if (s.endsWith('.')) {
        s = s.substring(0, s.length - 1);
      }
    }
    return s;
  }

  // Simple expression parser
  double _parseAndEvaluate(String expr) {
    if (expr.isEmpty) return 0;

    // Replace custom display characters with computer symbols
    String formatted = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', math.pi.toString())
        .replaceAll('e', math.e.toString());

    int pos = 0;

    late double Function() parseExpr;
    late double Function() parseTerm;
    late double Function() parseFactor;
    late double Function() parsePrimary;

    parsePrimary = () {
      if (pos >= formatted.length) return 0;

      // Functions
      final funcRegex = RegExp(r'^(sin|cos|tan|ln|log|√)\(');
      final match = funcRegex.matchAsPrefix(formatted.substring(pos));
      if (match != null) {
        String func = match.group(1)!;
        pos += match.end;
        double arg = parseExpr();
        if (pos < formatted.length && formatted[pos] == ')')
          pos++; // consume ')'

        switch (func) {
          case 'sin':
            return math.sin(arg * math.pi / 180.0); // degree input
          case 'cos':
            return math.cos(arg * math.pi / 180.0);
          case 'tan':
            return math.tan(arg * math.pi / 180.0);
          case 'ln':
            return math.log(arg);
          case 'log':
            return math.log(arg) / math.ln10;
          case '√':
            return math.sqrt(arg);
        }
      }

      if (formatted[pos] == '(') {
        pos++; // consume '('
        double val = parseExpr();
        if (pos < formatted.length && formatted[pos] == ')')
          pos++; // consume ')'
        return val;
      }

      if (formatted[pos] == '-') {
        pos++;
        return -parsePrimary();
      }

      // Numbers
      int start = pos;
      if (pos < formatted.length &&
          (formatted[pos] == '.' || _isDigit(formatted[pos]))) {
        while (pos < formatted.length &&
            (formatted[pos] == '.' || _isDigit(formatted[pos]))) {
          pos++;
        }
        return double.parse(formatted.substring(start, pos));
      }

      return 0;
    };

    parseFactor = () {
      double val = parsePrimary();
      while (pos < formatted.length) {
        if (formatted[pos] == '^') {
          pos++;
          double exponent = parsePrimary();
          val = math.pow(val, exponent).toDouble();
        } else if (formatted[pos] == '%') {
          pos++;
          val = val / 100.0;
        } else {
          break;
        }
      }
      return val;
    };

    parseTerm = () {
      double val = parseFactor();
      while (pos < formatted.length) {
        if (formatted[pos] == '*') {
          pos++;
          val *= parseFactor();
        } else if (formatted[pos] == '/') {
          pos++;
          double divisor = parseFactor();
          val /= divisor;
        } else {
          break;
        }
      }
      return val;
    };

    parseExpr = () {
      double val = parseTerm();
      while (pos < formatted.length) {
        if (formatted[pos] == '+') {
          pos++;
          val += parseTerm();
        } else if (formatted[pos] == '-') {
          pos++;
          val -= parseTerm();
        } else {
          break;
        }
      }
      return val;
    };

    double res = parseExpr();
    return res;
  }

  bool _isDigit(String s) {
    return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final basicKeys = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '(', ')'],
      ['=', 'Scientific'],
    ];

    final scientificKeys = [
      ['sin', 'cos', 'tan', 'C'],
      ['ln', 'log', '√', '⌫'],
      ['π', 'e', '^', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '(', ')'],
      ['=', 'Basic'],
    ];

    final keys = _scientific ? scientificKeys : basicKeys;

    return Column(
      children: [
        // Display Area inside BentoCard
        BentoCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Expression
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _expression.isEmpty ? '0' : _expression,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Live Result
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _result,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Keypad Area
        Expanded(
          flex: 4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _scientific ? 4 : 4,
                  childAspectRatio:
                      (constraints.maxWidth / 4) /
                      (constraints.maxHeight / keys.length),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: keys.expand((x) => x).length,
                itemBuilder: (context, index) {
                  final list = keys.expand((x) => x).toList();
                  final keyVal = list[index];

                  if (keyVal == 'Scientific' || keyVal == 'Basic') {
                    return BentoCard(
                      padding: EdgeInsets.zero,
                      color: Colors.transparent,
                      onTap: () {
                        setState(() {
                          _scientific = !_scientific;
                        });
                      },
                      child: Center(
                        child: Icon(
                          _scientific
                              ? Icons.arrow_back_rounded
                              : Icons.science_rounded,
                          color: theme.primaryColor,
                        ),
                      ),
                    );
                  }

                  final isOperator = [
                    '÷',
                    '×',
                    '-',
                    '+',
                    '=',
                    '%',
                    '^',
                  ].contains(keyVal);
                  final isClear = ['C', '⌫'].contains(keyVal);
                  final isEquals = keyVal == '=';

                  Color cardColor;
                  Color textColor;

                  if (isEquals) {
                    cardColor = theme.primaryColor;
                    textColor = Colors.white;
                  } else if (isOperator) {
                    cardColor = AppTheme.cardAltColor(isDark);
                    textColor = theme.primaryColor;
                  } else if (isClear) {
                    cardColor = isDark
                        ? const Color(0xFF3B1515)
                        : const Color(0xFFFCE4E4);
                    textColor = Colors.red;
                  } else {
                    cardColor = AppTheme.cardColor(isDark);
                    textColor = isDark ? Colors.white : Colors.black87;
                  }

                  return BentoCard(
                    padding: EdgeInsets.zero,
                    color: cardColor,
                    borderColor: isEquals ? theme.primaryColor : null,
                    onTap: () => _onKeyPress(keyVal),
                    child: Center(
                      child: Text(
                        keyVal,
                        style: TextStyle(
                          fontSize: _scientific && keyVal.length > 2 ? 14 : 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Quick history viewer toggle or footer
        if (provider.calcHistory.isNotEmpty) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.0),
                  ),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.translate(
                                'Riwayat Kalkulasi',
                                'Calculation History',
                              ),
                              style: theme.textTheme.titleMedium,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                provider.clearCalcHistory();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.calcHistory.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  provider.calcHistory[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: const Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 16,
                                ),
                                onTap: () {
                                  final split = provider.calcHistory[index]
                                      .split(' = ');
                                  setState(() {
                                    _expression = split[0];
                                    _result = split[1];
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  provider.translate('Lihat Riwayat', 'View History'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

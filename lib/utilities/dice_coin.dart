import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class DiceCoinWidget extends StatefulWidget {
  const DiceCoinWidget({super.key});

  @override
  State<DiceCoinWidget> createState() => _DiceCoinWidgetState();
}

class _DiceCoinWidgetState extends State<DiceCoinWidget>
    with SingleTickerProviderStateMixin {
  bool _isDiceMode = true;

  // Dice state
  int _diceCount = 1;
  List<int> _diceValues = [1];
  bool _isDiceRolling = false;

  // Coin state
  bool _isHeads = true;
  bool _isCoinFlipping = false;
  double _coinRotation = 0.0; // Rotation angle in radians
  Timer? _diceTimer;
  Timer? _coinTimer;

  final Random _random = Random();

  @override
  void dispose() {
    _diceTimer?.cancel();
    _coinTimer?.cancel();
    super.dispose();
  }

  void _rollDice() {
    if (_isDiceRolling) return;
    setState(() {
      _isDiceRolling = true;
    });

    int ticks = 0;
    _diceTimer?.cancel();
    _diceTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _diceValues = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);
      });
      ticks++;
      if (ticks > 10) {
        timer.cancel();
        _diceTimer = null;
        setState(() {
          _isDiceRolling = false;
        });
      }
    });
  }

  void _flipCoin() {
    if (_isCoinFlipping) return;
    setState(() {
      _isCoinFlipping = true;
    });

    int ticks = 0;
    _coinTimer?.cancel();
    _coinTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _coinRotation += pi / 4;
        _isHeads = _random.nextBool();
      });
      ticks++;
      if (ticks > 15) {
        timer.cancel();
        _coinTimer = null;
        setState(() {
          _coinRotation = 0.0; // Reset visual rotation
          _isCoinFlipping = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Mode Selector Tab (Dadu / Koin)
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      provider.translate('Kocok Dadu', 'Roll Dice'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isDiceMode ? Colors.white : null,
                      ),
                    ),
                  ),
                  selected: _isDiceMode,
                  selectedColor: theme.primaryColor,
                  backgroundColor: Colors.transparent,
                  onSelected: (val) {
                    if (val) setState(() => _isDiceMode = true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      provider.translate('Lempar Koin', 'Flip Coin'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !_isDiceMode ? Colors.white : null,
                      ),
                    ),
                  ),
                  selected: !_isDiceMode,
                  selectedColor: theme.primaryColor,
                  backgroundColor: Colors.transparent,
                  onSelected: (val) {
                    if (val) setState(() => _isDiceMode = false);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Main animation canvas
        Expanded(
          flex: 3,
          child: BentoCard(
            child: Center(
              child: _isDiceMode
                  ? _buildDiceCanvas(theme, isDark)
                  : _buildCoinCanvas(theme, isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Controls Bento
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _isDiceMode
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dice count adjuster
                    Row(
                      children: [
                        Text(
                          provider.translate('Jumlah Dadu:', 'Dice count:'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(4, (index) {
                          final count = index + 1;
                          final isSelected = _diceCount == count;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _diceCount = count;
                                  _diceValues = List.generate(count, (_) => 1);
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : (isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                  border: Border.all(
                                    color: AppTheme.borderColor(isDark),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "$count",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _rollDice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.controlRadius,
                          ),
                        ),
                      ),
                      child: Text(provider.translate('KOCOK', 'ROLL')),
                    ),
                  ],
                )
              : Center(
                  child: ElevatedButton.icon(
                    onPressed: _flipCoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.controlRadius,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.toll_rounded),
                    label: Text(provider.translate('LEMPAR KOIN', 'FLIP COIN')),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDiceCanvas(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: _diceValues.map((val) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.cardColor(isDark),
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            border: Border.all(color: theme.primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: _buildDiceFace(val, theme.primaryColor),
        );
      }).toList(),
    );
  }

  Widget _buildDiceFace(int val, Color color) {
    // Return dots on dice face based on value
    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color),
    );

    const Map<int, List<int>> diceDotsMap = {
      1: [4],
      2: [0, 8],
      3: [0, 4, 8],
      4: [0, 2, 6, 8],
      5: [0, 2, 4, 6, 8],
      6: [0, 2, 3, 5, 6, 8],
    };

    final indexList = diceDotsMap[val] ?? [];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        if (indexList.contains(index)) {
          return Center(child: dot);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCoinCanvas(ThemeData theme, bool isDark) {
    final provider = context.watch<AppProvider>();
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(_coinRotation),
      alignment: Alignment.center,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.neutralColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.secondaryColor, width: 6),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neutralColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isHeads
                    ? Icons.account_balance_rounded
                    : Icons.monetization_on_rounded,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                _isHeads
                    ? provider.translate('GAMBAR', 'HEADS')
                    : provider.translate('ANGKA', 'TAILS'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

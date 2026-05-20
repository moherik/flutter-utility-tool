import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

/// Reaction time test — tap when the screen turns green.
class SpeedTestWidget extends StatefulWidget {
  const SpeedTestWidget({super.key});

  @override
  State<SpeedTestWidget> createState() => _SpeedTestWidgetState();
}

class _SpeedTestWidgetState extends State<SpeedTestWidget> {
  _Phase _phase = _Phase.waiting;
  DateTime? _greenAt;
  Timer? _timer;
  int? _lastMs;
  final List<int> _history = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.waiting;
      _greenAt = null;
    });
    final delay = Duration(milliseconds: 1500 + (DateTime.now().millisecond % 2500));
    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.go;
        _greenAt = DateTime.now();
      });
    });
  }

  void _onTap() {
    switch (_phase) {
      case _Phase.waiting:
        _timer?.cancel();
        setState(() {
          _phase = _Phase.tooEarly;
        });
      case _Phase.go:
        final ms = DateTime.now().difference(_greenAt!).inMilliseconds;
        setState(() {
          _lastMs = ms;
          _history.insert(0, ms);
          if (_history.length > 5) _history.removeLast();
          _phase = _Phase.result;
        });
      case _Phase.tooEarly:
      case _Phase.result:
        _startRound();
    }
  }

  Color _bgColor(ThemeData theme) {
    switch (_phase) {
      case _Phase.waiting:
        return AppTheme.accentRose.withValues(alpha: 0.85);
      case _Phase.go:
        return AppTheme.statusSuccess(false);
      case _Phase.tooEarly:
        return AppTheme.statusWarning(false);
      case _Phase.result:
        return theme.colorScheme.primary.withValues(alpha: 0.85);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String message;
    switch (_phase) {
      case _Phase.waiting:
        message = provider.translate(
          'Tunggu hingga layar hijau…',
          'Wait until the screen turns green…',
        );
      case _Phase.go:
        message = provider.translate('KETUK SEKARANG!', 'TAP NOW!');
      case _Phase.tooEarly:
        message = provider.translate(
          'Terlalu cepat! Ketuk untuk coba lagi.',
          'Too early! Tap to try again.',
        );
      case _Phase.result:
        message = provider.translate(
          '$_lastMs ms — ketuk untuk ronde berikutnya',
          '$_lastMs ms — tap for next round',
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _bgColor(theme),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_history.isNotEmpty)
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.translate('Riwayat (ms)', 'History (ms)'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._history.map(
                  (ms) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$ms ms',
                      style: TextStyle(color: AppTheme.textSecondary(isDark)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _timer == null || _phase == _Phase.result || _phase == _Phase.tooEarly
              ? _startRound
              : null,
          child: Text(
            provider.translate('Mulai / Ulangi', 'Start / Retry'),
          ),
        ),
      ],
    );
  }
}

enum _Phase { waiting, go, tooEarly, result }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class StopwatchTimerWidget extends StatefulWidget {
  const StopwatchTimerWidget({Key? key}) : super(key: key);

  @override
  State<StopwatchTimerWidget> createState() => _StopwatchTimerWidgetState();
}

class _StopwatchTimerWidgetState extends State<StopwatchTimerWidget>
    with SingleTickerProviderStateMixin {
  bool _isStopwatchMode = true;

  // Stopwatch state
  bool _swIsRunning = false;
  int _swMilliseconds = 0;
  Timer? _swTimer;
  final List<String> _swLaps = [];

  // Timer state
  bool _tmIsRunning = false;
  bool _tmIsPaused = false;
  int _tmInitialSeconds = 60; // 1 min default
  int _tmRemainingSeconds = 60;
  Timer? _tmTimer;

  // Time picker values
  int _tmPickerMin = 1;
  int _tmPickerSec = 0;

  @override
  void dispose() {
    _swTimer?.cancel();
    _tmTimer?.cancel();
    super.dispose();
  }

  // --- Stopwatch functions ---
  void _startStopwatch() {
    if (_swIsRunning) return;
    setState(() {
      _swIsRunning = true;
    });
    _swTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _swMilliseconds += 10;
      });
    });
  }

  void _stopStopwatch() {
    if (!_swIsRunning) return;
    _swTimer?.cancel();
    setState(() {
      _swIsRunning = false;
    });
  }

  void _resetStopwatch() {
    _swTimer?.cancel();
    setState(() {
      _swIsRunning = false;
      _swMilliseconds = 0;
      _swLaps.clear();
    });
  }

  void _lapStopwatch() {
    if (!_swIsRunning) return;
    setState(() {
      _swLaps.insert(0, _formatMsToTime(_swMilliseconds));
    });
  }

  String _formatMsToTime(int totalMs) {
    int minutes = (totalMs ~/ 60000);
    int seconds = (totalMs % 60000) ~/ 1000;
    int hundredths = (totalMs % 1000) ~/ 10;

    String minStr = minutes.toString().padLeft(2, '0');
    String secStr = seconds.toString().padLeft(2, '0');
    String hundredthsStr = hundredths.toString().padLeft(2, '0');

    return "$minStr:$secStr.$hundredthsStr";
  }

  // --- Timer functions ---
  void _startTimer() {
    if (_tmIsRunning && !_tmIsPaused) return;

    if (!_tmIsPaused) {
      _tmInitialSeconds = (_tmPickerMin * 60) + _tmPickerSec;
      _tmRemainingSeconds = _tmInitialSeconds;
    }

    if (_tmRemainingSeconds <= 0) return;

    setState(() {
      _tmIsRunning = true;
      _tmIsPaused = false;
    });

    _tmTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tmRemainingSeconds > 0) {
        setState(() {
          _tmRemainingSeconds--;
        });
      } else {
        timer.cancel();
        _onTimerFinished();
      }
    });
  }

  void _pauseTimer() {
    if (!_tmIsRunning || _tmIsPaused) return;
    _tmTimer?.cancel();
    setState(() {
      _tmIsPaused = true;
    });
  }

  void _cancelTimer() {
    _tmTimer?.cancel();
    setState(() {
      _tmIsRunning = false;
      _tmIsPaused = false;
      _tmRemainingSeconds = _tmInitialSeconds;
    });
  }

  void _onTimerFinished() {
    setState(() {
      _tmIsRunning = false;
      _tmIsPaused = false;
    });
    // Trigger local audio-visual alert dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.alarm_on_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text('Time\'s Up!'),
            ],
          ),
          content: Text(
            context.read<AppProvider>().translate(
              'Timer Anda telah selesai.',
              'Your timer has finished.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatSecondsToTime(int totalSecs) {
    int minutes = totalSecs ~/ 60;
    int seconds = totalSecs % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Mode Tabs Bento
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'Stopwatch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isStopwatchMode ? Colors.white : null,
                      ),
                    ),
                  ),
                  selected: _isStopwatchMode,
                  selectedColor: theme.primaryColor,
                  backgroundColor: Colors.transparent,
                  onSelected: (val) {
                    if (val) setState(() => _isStopwatchMode = true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'Timer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !_isStopwatchMode ? Colors.white : null,
                      ),
                    ),
                  ),
                  selected: !_isStopwatchMode,
                  selectedColor: theme.primaryColor,
                  backgroundColor: Colors.transparent,
                  onSelected: (val) {
                    if (val) setState(() => _isStopwatchMode = false);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Main Display Bento Card
        Expanded(
          flex: 3,
          child: BentoCard(
            child: _isStopwatchMode
                ? _buildStopwatchLayout(theme, isDark)
                : _buildTimerLayout(theme, isDark),
          ),
        ),
        const SizedBox(height: 16),

        // Controls Bento Card
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: _isStopwatchMode
              ? _buildStopwatchControls(provider, theme)
              : _buildTimerControls(provider, theme),
        ),
      ],
    );
  }

  // --- Layout Builders ---
  Widget _buildStopwatchLayout(ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatMsToTime(_swMilliseconds),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: _swIsRunning
                ? theme.primaryColor
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        if (_swLaps.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _swLaps.length,
              itemBuilder: (context, index) {
                final lapNum = _swLaps.length - index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lap $lapNum',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _swLaps[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: Center(
              child: Text(
                context.read<AppProvider>().translate(
                  'Belum ada lap tercatat',
                  'No laps recorded',
                ),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStopwatchControls(AppProvider provider, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_swIsRunning) ...[
          OutlinedButton.icon(
            onPressed: _lapStopwatch,
            icon: const Icon(Icons.flag_rounded),
            label: Text(provider.translate('LAP', 'LAP')),
          ),
          ElevatedButton.icon(
            onPressed: _stopStopwatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.pause_rounded),
            label: Text(provider.translate('JEDA', 'PAUSE')),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _swMilliseconds > 0 ? _resetStopwatch : null,
            icon: const Icon(Icons.replay_rounded),
            label: Text(provider.translate('ULANG', 'RESET')),
          ),
          ElevatedButton.icon(
            onPressed: _startStopwatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(provider.translate('MULAI', 'START')),
          ),
        ],
      ],
    );
  }

  Widget _buildTimerLayout(ThemeData theme, bool isDark) {
    if (_tmIsRunning || _tmIsPaused) {
      // Countdown ring representation
      final double progress = _tmInitialSeconds > 0
          ? _tmRemainingSeconds / _tmInitialSeconds
          : 0.0;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  color: theme.primaryColor,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              Text(
                _formatSecondsToTime(_tmRemainingSeconds),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Set duration wheel interface
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.read<AppProvider>().translate('Atur Waktu', 'Set Duration'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimePickerColumn(
              val: _tmPickerMin,
              label: 'Min',
              onAdd: () {
                if (_tmPickerMin < 99) setState(() => _tmPickerMin++);
              },
              onRemove: () {
                if (_tmPickerMin > 0) setState(() => _tmPickerMin--);
              },
            ),
            const Text(
              ':',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            _buildTimePickerColumn(
              val: _tmPickerSec,
              label: 'Sec',
              onAdd: () {
                if (_tmPickerSec < 59) {
                  setState(() => _tmPickerSec++);
                } else {
                  setState(() => _tmPickerSec = 0);
                }
              },
              onRemove: () {
                if (_tmPickerSec > 0) {
                  setState(() => _tmPickerSec--);
                } else {
                  setState(() => _tmPickerSec = 59);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePickerColumn({
    required int val,
    required String label,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 32),
            onPressed: onAdd,
          ),
          Text(
            val.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControls(AppProvider provider, ThemeData theme) {
    if (_tmIsRunning || _tmIsPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton.icon(
            onPressed: _cancelTimer,
            icon: const Icon(Icons.cancel_rounded),
            label: Text(provider.translate('BATAL', 'CANCEL')),
          ),
          if (_tmIsPaused)
            ElevatedButton.icon(
              onPressed: _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(provider.translate('MULAI', 'RESUME')),
            )
          else
            ElevatedButton.icon(
              onPressed: _pauseTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.pause_rounded),
              label: Text(provider.translate('JEDA', 'PAUSE')),
            ),
        ],
      );
    }

    return Center(
      child: ElevatedButton.icon(
        onPressed: (_tmPickerMin == 0 && _tmPickerSec == 0)
            ? null
            : _startTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(provider.translate('MULAI TIMER', 'START TIMER')),
      ),
    );
  }
}

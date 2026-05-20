import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class MetronomeWidget extends StatefulWidget {
  const MetronomeWidget({Key? key}) : super(key: key);

  @override
  State<MetronomeWidget> createState() => _MetronomeWidgetState();
}

class _MetronomeWidgetState extends State<MetronomeWidget> {
  int _bpm = 100;
  bool _isPlaying = false;
  Timer? _timer;
  int _currentBeat = 0;
  int _beatsPerMeasure = 4;

  // Tap tempo state
  List<DateTime> _tapTimes = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startMetronome();
    } else {
      _timer?.cancel();
    }
  }

  void _startMetronome() {
    _timer?.cancel();
    final intervalMs = (60000 / _bpm).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      setState(() {
        _currentBeat = (_currentBeat + 1) % _beatsPerMeasure;
      });
      _playTickSound();
    });
  }

  void _playTickSound() {
    // Generate light haptic feedback to simulate click feel
    HapticFeedback.lightImpact();
    // In Flutter, to play real sound offline without heavy assets/packages,
    // haptics + visual flash is extremely reliable and lightweight.
  }

  void _tapTempo() {
    final now = DateTime.now();
    _tapTimes.add(now);

    // Keep last 4 taps
    if (_tapTimes.length > 4) {
      _tapTimes.removeAt(0);
    }

    if (_tapTimes.length >= 2) {
      double totalDiffMs = 0;
      for (int i = 0; i < _tapTimes.length - 1; i++) {
        totalDiffMs += _tapTimes[i + 1].difference(_tapTimes[i]).inMilliseconds;
      }
      final avgDiffMs = totalDiffMs / (_tapTimes.length - 1);
      final calculatedBpm = (60000 / avgDiffMs).round();

      if (calculatedBpm >= 40 && calculatedBpm <= 240) {
        setState(() {
          _bpm = calculatedBpm;
        });
        if (_isPlaying) {
          _startMetronome(); // restart with new BPM
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Visual Beat Indicator Card
        Expanded(
          flex: 2,
          child: BentoCard(
            color: _isPlaying && _currentBeat == 0
                ? theme.primaryColor.withOpacity(0.15)
                : null,
            borderColor: _isPlaying && _currentBeat == 0
                ? theme.primaryColor
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Beats row indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_beatsPerMeasure, (index) {
                    final isActive = _isPlaying && _currentBeat == index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? (index == 0 ? Colors.red : theme.primaryColor)
                            : (isDark ? Colors.white12 : Colors.black12),
                        border: Border.all(
                          color: isActive ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color:
                                      (index == 0
                                              ? Colors.red
                                              : theme.primaryColor)
                                          .withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : [],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // BPM Text
                Text(
                  "$_bpm",
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: _isPlaying
                        ? theme.primaryColor
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const Text(
                  'BPM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Controls Bento Card
        Expanded(
          flex: 2,
          child: BentoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Beats per measure adjuster
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate(
                        'Ketukan per Bar',
                        'Beats per Measure',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<int>(
                      value: _beatsPerMeasure,
                      underline: const SizedBox.shrink(),
                      items: [2, 3, 4, 5, 6].map((int val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Text(
                            "$val",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _beatsPerMeasure = val;
                            _currentBeat = 0;
                          });
                        }
                      },
                    ),
                  ],
                ),

                const Divider(),

                // BPM Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TEMPO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _bpm <= 60
                          ? 'Adagio'
                          : (_bpm <= 100
                                ? 'Andante'
                                : (_bpm <= 120 ? 'Moderato' : 'Allegro')),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _bpm.toDouble(),
                  min: 40,
                  max: 240,
                  activeColor: theme.primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _bpm = val.round();
                    });
                    if (_isPlaying) {
                      _startMetronome();
                    }
                  },
                ),

                const Divider(),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _togglePlay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlaying
                            ? Colors.red
                            : theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: Icon(
                        _isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(_isPlaying ? 'STOP' : 'START'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _tapTempo,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: const Icon(Icons.touch_app_rounded),
                      label: const Text('TAP TEMPO'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

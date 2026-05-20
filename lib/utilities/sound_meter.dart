import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class SoundMeterWidget extends StatefulWidget {
  const SoundMeterWidget({Key? key}) : super(key: key);

  @override
  State<SoundMeterWidget> createState() => _SoundMeterWidgetState();
}

class _SoundMeterWidgetState extends State<SoundMeterWidget> {
  bool _isListening = false;
  double _db = 30.0;
  double _maxDb = 30.0;
  Timer? _timer;
  final List<double> _waveHistory = List.filled(30, 0.0);
  final Random _random = Random();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _startSimulatedMic();
    } else {
      _timer?.cancel();
    }
  }

  void _startSimulatedMic() {
    _timer?.cancel();
    // Update noise readings every 100ms
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Base noise level around 30dB, fluctuating up to 85dB normally
        // unless there is a simulated spike
        double newDb = 35 + _random.nextDouble() * 20;

        // Randomly simulate vocal/loud sound spikes
        if (_random.nextInt(10) == 0) {
          newDb += _random.nextDouble() * 35;
        }

        _db = newDb;
        if (_db > _maxDb) {
          _maxDb = _db;
        }

        // Shift wave history
        _waveHistory.removeAt(0);
        _waveHistory.add(_db);
      });
    });
  }

  void _resetMax() {
    setState(() {
      _maxDb = _db;
    });
  }

  String _getNoiseLabel(double db, AppProvider provider) {
    if (db < 40)
      return provider.translate(
        'Sangat Sunyi (Perpustakaan)',
        'Very Quiet (Library)',
      );
    if (db < 60)
      return provider.translate(
        'Sunyi (Kantor Tenang)',
        'Quiet (Normal Office)',
      );
    if (db < 70)
      return provider.translate(
        'Sedang (Percakapan)',
        'Moderate (Conversation)',
      );
    if (db < 85)
      return provider.translate(
        'Bising (Jalanan Ramai)',
        'Loud (Heavy Traffic)',
      );
    return provider.translate(
      'Sangat Bising (Berbahaya)',
      'Very Loud (Danger)',
    );
  }

  Color _getNoiseColor(double db) {
    if (db < 60) return Colors.green;
    if (db < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final noiseColor = _getNoiseColor(_db);

    return Column(
      children: [
        // Main Dial & Decibel Indicator
        Expanded(
          flex: 3,
          child: BentoCard(
            color: _isListening ? noiseColor.withOpacity(0.08) : null,
            borderColor: _isListening ? noiseColor : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wave Visualizer
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: WavePainter(_waveHistory, noiseColor),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  _isListening ? "${_db.toStringAsFixed(1)} dB" : "-- dB",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: _isListening ? noiseColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  _isListening
                      ? _getNoiseLabel(_db, provider)
                      : provider.translate('Mikrofon Mati', 'Sound Meter Off'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Statistics (Max dB) & Reset
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.translate(
                      'Tingkat Kebisingan Maksimal',
                      'Max Noise Level',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isListening ? "${_maxDb.toStringAsFixed(1)} dB" : "-- dB",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: _isListening ? _resetMax : null,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(provider.translate('RESET MAKS', 'RESET MAX')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Controls (Toggle Listening)
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: _toggleListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: Icon(
                _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
              ),
              label: Text(
                _isListening
                    ? provider.translate('MATIKAN MIKROFON', 'STOP LISTENING')
                    : provider.translate(
                        'AKTIFKAN MIKROFON',
                        'START LISTENING',
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final List<double> history;
  final Color waveColor;

  WavePainter(this.history, this.waveColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final step = size.width / (history.length - 1);
    final midY = size.height / 2;

    for (int i = 0; i < history.length; i++) {
      // Map dB to visual amplitude height relative to canvas bounds
      final amp = ((history[i] - 30) / 70) * (size.height / 2);
      final x = i * step;
      final y = midY + (i % 2 == 0 ? amp : -amp);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

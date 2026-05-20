import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class SoundMeterWidget extends StatefulWidget {
  const SoundMeterWidget({super.key});

  @override
  State<SoundMeterWidget> createState() => _SoundMeterWidgetState();
}

class _SoundMeterWidgetState extends State<SoundMeterWidget> {
  bool _isListening = false;
  bool _isStarting = false;
  double _db = 30.0;
  double _maxDb = 30.0;
  String? _errorMessage;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final List<double> _waveHistory = List.filled(30, 30.0);

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isStarting) return;
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      var permission = await Permission.microphone.status;
      if (!permission.isGranted) {
        permission = await Permission.microphone.request();
      }

      if (!permission.isGranted) {
        if (!mounted) return;
        setState(() {
          _isStarting = false;
          _isListening = false;
          _errorMessage = context.read<AppProvider>().translate(
            'Izin mikrofon ditolak. Aktifkan izin mikrofon untuk memakai Sound Meter.',
            'Microphone permission was denied. Enable microphone permission to use Sound Meter.',
          );
        });
        return;
      }

      _noiseMeter ??= NoiseMeter();
      await _noiseSubscription?.cancel();
      _noiseSubscription = _noiseMeter!.noise.listen(
        _onNoiseData,
        onError: _onNoiseError,
        cancelOnError: true,
      );

      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _isListening = true;
      });
    } catch (error) {
      _onNoiseError(error);
    }
  }

  Future<void> _stopListening() async {
    await _noiseSubscription?.cancel();
    _noiseSubscription = null;
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _isStarting = false;
    });
  }

  void _onNoiseData(NoiseReading reading) {
    if (!mounted) return;

    final meanDb = reading.meanDecibel;
    if (meanDb.isNaN || meanDb.isInfinite) return;

    setState(() {
      _db = meanDb.clamp(0.0, 140.0);
      _maxDb = reading.maxDecibel.isFinite
          ? reading.maxDecibel.clamp(_maxDb, 140.0)
          : _maxDb;

      _waveHistory.removeAt(0);
      _waveHistory.add(_db);
    });
  }

  void _onNoiseError(Object error) {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _isStarting = false;
      _errorMessage = context.read<AppProvider>().translate(
        'Mikrofon tidak bisa diakses pada perangkat atau platform ini.',
        'The microphone cannot be accessed on this device or platform.',
      );
    });
  }

  void _resetMax() {
    setState(() {
      _maxDb = _db;
    });
  }

  String _getNoiseLabel(double db, AppProvider provider) {
    if (db < 40) {
      return provider.translate(
        'Sangat Sunyi (Perpustakaan)',
        'Very Quiet (Library)',
      );
    }
    if (db < 60) {
      return provider.translate(
        'Sunyi (Kantor Tenang)',
        'Quiet (Normal Office)',
      );
    }
    if (db < 70) {
      return provider.translate(
        'Sedang (Percakapan)',
        'Moderate (Conversation)',
      );
    }
    if (db < 85) {
      return provider.translate(
        'Bising (Jalanan Ramai)',
        'Loud (Heavy Traffic)',
      );
    }
    return provider.translate(
      'Sangat Bising (Berbahaya)',
      'Very Loud (Danger)',
    );
  }

  Color _getNoiseColor(double db) {
    if (db < 60) return AppTheme.tertiaryColor;
    if (db < 80) return AppTheme.neutralColor;
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final noiseColor = _getNoiseColor(_db);

    return Column(
      children: [
        if (_errorMessage != null) ...[
          BentoCard(
            color: AppTheme.primaryColor.withOpacity(0.08),
            borderColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

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
                  _isStarting
                      ? provider.translate(
                          'Mengaktifkan mikrofon...',
                          'Starting microphone...',
                        )
                      : (_isListening
                            ? _getNoiseLabel(_db, provider)
                            : provider.translate(
                                'Mikrofon Mati',
                                'Sound Meter Off',
                              )),
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
                    borderRadius: BorderRadius.circular(AppTheme.controlRadius),
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
              onPressed: _isStarting ? null : _toggleListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening
                    ? AppTheme.primaryColor
                    : theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.controlRadius),
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

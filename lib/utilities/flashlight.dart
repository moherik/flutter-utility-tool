import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class FlashlightWidget extends StatefulWidget {
  const FlashlightWidget({super.key});

  @override
  State<FlashlightWidget> createState() => _FlashlightWidgetState();
}

class _FlashlightWidgetState extends State<FlashlightWidget> {
  bool _isTorchOn = false;
  bool _hasTorch = true;
  double _strobeSpeed = 0.0; // 0 = static, 1-10 = strobe speed
  Timer? _strobeTimer;
  bool _strobeState = false;
  bool _sosMode = false;
  Timer? _sosTimer;
  int _sosIndex = 0;

  // Screen light controls
  bool _useScreen = false;
  Color _screenColor = Colors.white;
  double _screenBrightness = 1.0;

  // SOS patterns in milliseconds: S (200, 200, 200), O (600, 200, 600), S (200, 200, 200)
  // represented as state durations: on, off, on, off...
  final List<int> _sosPattern = [
    200, 200, 200, 200, 200, 400, // S (dot, dot, dot)
    600, 200, 600, 200, 600, 400, // O (dash, dash, dash)
    200, 200, 200, 200, 200, 2000, // S (dot, dot, dot) + pause
  ];

  @override
  void initState() {
    super.initState();
    _checkTorchAvailability();
  }

  @override
  void dispose() {
    _stopStrobe();
    _stopSos();
    if (_isTorchOn && !_useScreen) {
      TorchLight.disableTorch().catchError((_) {});
    }
    super.dispose();
  }

  Future<void> _checkTorchAvailability() async {
    try {
      final isAvailable = await TorchLight.isTorchAvailable();
      if (!mounted) return;
      setState(() {
        _hasTorch = isAvailable;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasTorch = false;
      });
    }
  }

  Future<void> _toggleTorch() async {
    if (_useScreen) {
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
      return;
    }

    if (!_hasTorch) {
      // Graceful fallback to screen light
      setState(() {
        _useScreen = true;
        _isTorchOn = !_isTorchOn;
      });
      return;
    }

    try {
      if (_isTorchOn) {
        await _turnOffTorch();
      } else {
        await _turnOnTorch();
      }
    } catch (e) {
      // Fail fallback
      if (!mounted) return;
      setState(() {
        _useScreen = true;
        _isTorchOn = !_isTorchOn;
      });
    }
  }

  Future<void> _turnOnTorch() async {
    try {
      await TorchLight.enableTorch();
      if (!mounted) return;
      setState(() {
        _isTorchOn = true;
      });
    } catch (_) {}
  }

  Future<void> _turnOffTorch() async {
    try {
      await TorchLight.disableTorch();
      if (!mounted) return;
      setState(() {
        _isTorchOn = false;
      });
    } catch (_) {}
  }

  void _onStrobeSpeedChanged(double val) {
    setState(() {
      _strobeSpeed = val;
      _sosMode = false;
      _stopSos();
    });

    _stopStrobe();
    if (val > 0.0) {
      final intervalMs = (1000 / val).round();
      _strobeTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
        timer,
      ) {
        _strobeState = !_strobeState;
        _applyStrobeState(_strobeState);
      });
    } else {
      _applyStrobeState(_isTorchOn);
    }
  }

  void _applyStrobeState(bool on) {
    if (_useScreen) {
      if (!mounted) return;
      setState(() {
        _isTorchOn = on;
      });
      return;
    }

    if (on) {
      TorchLight.enableTorch().catchError((_) {});
    } else {
      TorchLight.disableTorch().catchError((_) {});
    }
  }

  void _stopStrobe() {
    _strobeTimer?.cancel();
    _strobeTimer = null;
  }

  void _toggleSos() {
    setState(() {
      _sosMode = !_sosMode;
      _strobeSpeed = 0.0;
      _stopStrobe();
    });

    if (_sosMode) {
      _sosIndex = 0;
      _runSosCycle();
    } else {
      _stopSos();
      _applyStrobeState(_isTorchOn);
    }
  }

  void _runSosCycle() {
    if (!_sosMode) return;

    final duration = _sosPattern[_sosIndex];
    final isOn = _sosIndex % 2 == 0;

    _applyStrobeState(isOn);

    _sosTimer = Timer(Duration(milliseconds: duration), () {
      if (mounted && _sosMode) {
        _sosIndex = (_sosIndex + 1) % _sosPattern.length;
        _runSosCycle();
      }
    });
  }

  void _stopSos() {
    _sosTimer?.cancel();
    _sosTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    if (_useScreen && _isTorchOn) {
      // Full screen mode for screen flashlight
      return Scaffold(
        backgroundColor: _screenColor.withOpacity(_screenBrightness),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isTorchOn = false;
                });
              },
              child: Center(
                child: Text(
                  provider.translate('Ketuk untuk Keluar', 'Tap to Exit'),
                  style: TextStyle(
                    color: _screenColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(1, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: BentoCard(
                color: Colors.black.withOpacity(0.6),
                borderColor: Colors.white24,
                child: Column(
                  children: [
                    Slider(
                      value: _screenBrightness,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (val) {
                        setState(() {
                          _screenBrightness = val;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _colorDot(Colors.white),
                        _colorDot(AppTheme.primaryColor),
                        _colorDot(AppTheme.tertiaryColor),
                        _colorDot(AppTheme.secondaryColor),
                        _colorDot(AppTheme.neutralColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Main Switch Bento Box
        Expanded(
          flex: 2,
          child: BentoCard(
            color: _isTorchOn ? theme.primaryColor.withOpacity(0.1) : null,
            borderColor: _isTorchOn ? theme.primaryColor : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flashlight_on_rounded,
                  size: 80,
                  color: _isTorchOn ? theme.primaryColor : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _isTorchOn
                      ? provider.translate('Senter Aktif', 'Flashlight On')
                      : provider.translate('Senter Mati', 'Flashlight Off'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _toggleTorch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTorchOn
                        ? theme.primaryColor
                        : Colors.grey[700],
                    foregroundColor: Colors.white,
                    shape: AppTheme.controlShape,
                    padding: const EdgeInsets.all(22),
                  ),
                  child: const Icon(Icons.power_settings_new_rounded, size: 36),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Controls Bento Box
        Expanded(
          flex: 2,
          child: BentoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mode Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.translate('Gunakan Layar', 'Use Screen Light'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _useScreen,
                      activeThumbColor: theme.primaryColor,
                      onChanged: (val) {
                        if (_isTorchOn) {
                          _turnOffTorch();
                        }
                        setState(() {
                          _useScreen = val;
                          _isTorchOn = false;
                        });
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Strobe
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.translate(
                            'Kecepatan Kedip (Strobe)',
                            'Strobe Blinking Speed',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${_strobeSpeed.toStringAsFixed(1)} Hz",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _strobeSpeed,
                      min: 0.0,
                      max: 10.0,
                      divisions: 10,
                      activeColor: theme.primaryColor,
                      onChanged: _onStrobeSpeedChanged,
                    ),
                  ],
                ),

                const Divider(),

                // SOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mode SOS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          provider.translate(
                            'Pola sinyal darurat',
                            'Emergency signal pattern',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleSos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sosMode
                            ? AppTheme.primaryColor
                            : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        _sosMode ? Icons.stop_rounded : Icons.warning_rounded,
                      ),
                      label: Text(_sosMode ? 'STOP' : 'SOS'),
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

  Widget _colorDot(Color color) {
    final isSelected = _screenColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _screenColor = color;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
        ),
      ),
    );
  }
}

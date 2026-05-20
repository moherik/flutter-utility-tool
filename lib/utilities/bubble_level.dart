import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bento_card.dart';

class BubbleLevelWidget extends StatefulWidget {
  const BubbleLevelWidget({Key? key}) : super(key: key);

  @override
  State<BubbleLevelWidget> createState() => _BubbleLevelWidgetState();
}

class _BubbleLevelWidgetState extends State<BubbleLevelWidget> {
  double _x = 0.0;
  double _y = 0.0;
  double _z = 9.8;
  StreamSubscription? _subscription;
  bool _sensorAvailable = true;

  // Simulator fallbacks
  double _simX = 0.0;
  double _simY = 0.0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    try {
      _subscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;
            _sensorAvailable = true;
          });
        },
        onError: (error) {
          setState(() {
            _sensorAvailable = false;
          });
        },
        cancelOnError: true,
      );
    } catch (_) {
      setState(() {
        _sensorAvailable = false;
      });
    }

    // After 2 seconds, if we didn't receive any data, fallback to simulation mode
    Timer(const Duration(seconds: 2), () {
      if (_x == 0.0 && _y == 0.0 && _z == 9.8) {
        setState(() {
          _sensorAvailable = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Standard accelerometer mapping
    // Flat on table: X ≈ 0, Y ≈ 0, Z ≈ 9.8
    // Tilt Left/Right moves X. Tilt Up/Down moves Y.
    double xVal = _sensorAvailable ? _x : _simX;
    double yVal = _sensorAvailable ? _y : _simY;

    // Calculate angles
    // Pitch (up-down) and Roll (left-right) in degrees
    // pitch = atan2(y, z) * 180 / pi
    // roll = atan2(-x, sqrt(y*y + z*z)) * 180 / pi
    double pitch = (yVal * 9.0); // Simple linear approximation for readability
    double roll = (-xVal * 9.0);

    if (pitch.abs() > 90) pitch = pitch.sign * 90;
    if (roll.abs() > 90) roll = roll.sign * 90;

    // Check if flat (within 0.5 degrees)
    bool isFlat = pitch.abs() < 1.0 && roll.abs() < 1.0;

    return Column(
      children: [
        // Sensor Status Banner
        if (!_sensorAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: BentoCard(
              color: Colors.amber.withOpacity(0.15),
              borderColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.translate(
                        'Sensor tidak tersedia. Jalankan dalam Mode Simulasi (Gunakan Sentuhan).',
                        'Sensor unavailable. Running in Simulation Mode (Use Touch).',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // circular bubble display
        Expanded(
          flex: 2,
          child: GestureDetector(
            onPanUpdate: _sensorAvailable
                ? null
                : (details) {
                    // Update simulation bubble positioning based on gesture
                    setState(() {
                      _simX += details.delta.dx / 15.0;
                      _simY -= details.delta.dy / 15.0;
                      if (_simX > 10) _simX = 10;
                      if (_simX < -10) _simX = -10;
                      if (_simY > 10) _simY = 10;
                      if (_simY < -10) _simY = -10;
                    });
                  },
            onPanEnd: _sensorAvailable
                ? null
                : (_) {
                    // Return bubble to center slowly if simulator
                    Timer.periodic(const Duration(milliseconds: 16), (t) {
                      if (_sensorAvailable ||
                          (_simX.abs() < 0.1 && _simY.abs() < 0.1)) {
                        t.cancel();
                        setState(() {
                          _simX = 0;
                          _simY = 0;
                        });
                      } else {
                        setState(() {
                          _simX *= 0.85;
                          _simY *= 0.85;
                        });
                      }
                    });
                  },
            child: BentoCard(
              color: isFlat ? Colors.green.withOpacity(0.05) : null,
              borderColor: isFlat ? Colors.green : null,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth * 0.7
                        : constraints.maxHeight * 0.7;

                    // Calculate bubble positions: max accelerometer displacement ~10 m/s2
                    // Map xVal (-10 to 10) and yVal (-10 to 10) to bubble coordinates
                    double maxDisplacement =
                        size / 2 - 25; // 25 is bubble radius
                    double bubbleX = (-xVal / 9.8) * maxDisplacement;
                    double bubbleY = (yVal / 9.8) * maxDisplacement;

                    // Cap bubble inside boundary
                    if (bubbleX.abs() > maxDisplacement)
                      bubbleX = bubbleX.sign * maxDisplacement;
                    if (bubbleY.abs() > maxDisplacement)
                      bubbleY = bubbleY.sign * maxDisplacement;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer leveling circle
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFlat
                                  ? Colors.green
                                  : (isDark ? Colors.white24 : Colors.black12),
                              width: 3,
                            ),
                          ),
                        ),
                        // Inner circle target
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFlat
                                  ? Colors.green
                                  : Colors.red.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Horizontal crosshair
                        Container(
                          width: size - 10,
                          height: 1.5,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        // Vertical crosshair
                        Container(
                          width: 1.5,
                          height: size - 10,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        // Bubble indicator
                        Transform.translate(
                          offset: Offset(bubbleX, bubbleY),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFlat ? Colors.green : theme.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isFlat
                                              ? Colors.green
                                              : theme.primaryColor)
                                          .withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Angle Readings and Spirit Tube
        Expanded(
          flex: 1,
          child: Row(
            children: [
              // Pitch Reading Card
              Expanded(
                child: BentoCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PITCH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${pitch.toStringAsFixed(1)}°",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isFlat
                              ? Colors.green
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Roll Reading Card
              Expanded(
                child: BentoCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ROLL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${roll.toStringAsFixed(1)}°",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isFlat
                              ? Colors.green
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double _heading = 0.0;
  StreamSubscription? _subscription;
  bool _sensorAvailable = true;
  bool _hasSensorEvent = false;
  Timer? _fallbackTimer;
  double _manualAngle = 0.0; // Manual rotation for simulator

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    try {
      _subscription = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          // Simple heading calculation: angle = atan2(y, x)
          // Adjust based on typical device coordinate alignment.
          double angle = math.atan2(event.y, event.x) * 180 / math.pi;

          // Normalize to 0-360 degrees
          angle = (angle + 360) % 360;

          if (!mounted) return;
          setState(() {
            // Apply smoothing or just direct assignment
            _heading = angle;
            _sensorAvailable = true;
            _hasSensorEvent = true;
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _sensorAvailable = false;
          });
        },
        cancelOnError: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sensorAvailable = false;
      });
    }

    _fallbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !_hasSensorEvent) {
        setState(() {
          _sensorAvailable = false;
        });
      }
    });
  }

  String _getDirectionString(double degree) {
    if (degree >= 337.5 || degree < 22.5) return 'N'; // Utara (North)
    if (degree >= 22.5 && degree < 67.5) return 'NE'; // Timur Laut
    if (degree >= 67.5 && degree < 112.5) return 'E'; // Timur (East)
    if (degree >= 112.5 && degree < 157.5) return 'SE'; // Tenggara
    if (degree >= 157.5 && degree < 202.5) return 'S'; // Selatan (South)
    if (degree >= 202.5 && degree < 247.5) return 'SW'; // Barat Daya
    if (degree >= 247.5 && degree < 292.5) return 'W'; // Barat (West)
    return 'NW'; // Barat Laut
  }

  String _getDirectionFull(double degree, AppProvider p) {
    final dir = _getDirectionString(degree);
    switch (dir) {
      case 'N':
        return p.translate('UTARA', 'NORTH');
      case 'NE':
        return p.translate('TIMUR LAUT', 'NORTHEAST');
      case 'E':
        return p.translate('TIMUR', 'EAST');
      case 'SE':
        return p.translate('TENGGARA', 'SOUTHEAST');
      case 'S':
        return p.translate('SELATAN', 'SOUTH');
      case 'SW':
        return p.translate('BARAT DAYA', 'SOUTHWEST');
      case 'W':
        return p.translate('BARAT', 'WEST');
      default:
        return p.translate('BARAT LAUT', 'NORTHWEST');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final angle = _sensorAvailable ? _heading : _manualAngle;

    return Column(
      children: [
        if (!_sensorAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: BentoCard(
              color: AppTheme.neutralColor.withOpacity(0.15),
              borderColor: AppTheme.neutralColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: AppTheme.neutralColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.translate(
                        'Sensor magnet tidak tersedia. Putar kompas secara manual dengan menyeret layar.',
                        'Magnetometer sensor unavailable. Rotate the compass manually by dragging the screen.',
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

        // Dial Display inside BentoCard
        Expanded(
          flex: 3,
          child: GestureDetector(
            onPanUpdate: _sensorAvailable
                ? null
                : (details) {
                    setState(() {
                      // Adjust manual angle based on drag delta
                      _manualAngle =
                          (_manualAngle + details.delta.dx / 2.0) % 360;
                    });
                  },
            child: BentoCard(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth * 0.8
                        : constraints.maxHeight * 0.8;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass Ring / Dial (Rotating)
                        Transform.rotate(
                          angle: -angle * math.pi / 180.0,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black12,
                                width: 2,
                              ),
                              gradient: RadialGradient(
                                colors: [
                                  theme.cardColor,
                                  AppTheme.cardAltColor(isDark),
                                ],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Cardinal Direction labels (N, E, S, W)
                                Positioned(
                                  top: 15,
                                  child: Text(
                                    'N',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  child: const Text(
                                    'S',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 15,
                                  child: const Text(
                                    'E',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 15,
                                  child: const Text(
                                    'W',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Custom Compass ticks or dial decorations
                                ...List.generate(36, (index) {
                                  double tickAngle = index * 10 * math.pi / 180;
                                  bool isMajor = index % 9 == 0; // N, E, S, W
                                  return Transform.rotate(
                                    angle: tickAngle,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        width: isMajor ? 3 : 1,
                                        height: isMajor ? 12 : 6,
                                        color: isMajor
                                            ? (index == 0
                                                  ? theme.primaryColor
                                                  : Colors.grey[500])
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Center compass needle / pointer (Static overlay)
                        CustomPaint(
                          size: Size(30, size * 0.7),
                          painter: CompassNeedlePainter(theme.primaryColor),
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

        // Angle and Direction Status Bento Card
        Expanded(
          flex: 1,
          child: BentoCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.translate('DERAJAT', 'HEADING'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${angle.round()}°",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const VerticalDivider(width: 32, thickness: 1),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.translate('ARAH MATAPAT', 'DIRECTION'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getDirectionFull(angle, provider),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
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

class CompassNeedlePainter extends CustomPainter {
  final Color primaryColor;
  CompassNeedlePainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final paintGrey = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    final paintCenter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paintCenterBorder = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pathNorth = Path();
    pathNorth.moveTo(size.width / 2, 0);
    pathNorth.lineTo(size.width, size.height / 2);
    pathNorth.lineTo(size.width / 2, size.height / 2 - 5);
    pathNorth.lineTo(0, size.height / 2);
    pathNorth.close();

    final pathSouth = Path();
    pathSouth.moveTo(size.width / 2, size.height);
    pathSouth.lineTo(size.width, size.height / 2);
    pathSouth.lineTo(size.width / 2, size.height / 2 + 5);
    pathSouth.lineTo(0, size.height / 2);
    pathSouth.close();

    canvas.drawPath(pathNorth, paintRed);
    canvas.drawPath(pathSouth, paintGrey);

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, paintCenter);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      6,
      paintCenterBorder,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class ScreenRulerWidget extends StatefulWidget {
  const ScreenRulerWidget({super.key});

  @override
  State<ScreenRulerWidget> createState() => _ScreenRulerWidgetState();
}

class _ScreenRulerWidgetState extends State<ScreenRulerWidget> {
  double _sliderPos = 150.0; // Caliper drag position in pixels
  final bool _useCm = true;

  // Conversion values (Standard mobile screen PPI mapping approximation)
  // ~160 logical pixels per inch on standard Flutter devices.
  static const double pixelsPerInch = 160.0;
  static const double pixelsPerCm = pixelsPerInch / 2.54;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate real values at caliper position
    final cmValue = _sliderPos / pixelsPerCm;
    final inchValue = _sliderPos / pixelsPerInch;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxH =
            constraints.maxHeight - 80; // reserve space for bottom control card
        if (_sliderPos > maxH) {
          _sliderPos = maxH;
        }

        return Column(
          children: [
            // Ruler Graphic Area
            Expanded(
              child: BentoCard(
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    // Centimeter scale (Left Side)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 70,
                      child: CustomPaint(
                        painter: RulerScalePainter(
                          isLeft: true,
                          pixelsPerUnit: pixelsPerCm,
                          unitLabel: 'cm',
                          themeColor: isDark ? Colors.white30 : Colors.black12,
                          textColor: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),

                    // Inch scale (Right Side)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 70,
                      child: CustomPaint(
                        painter: RulerScalePainter(
                          isLeft: false,
                          pixelsPerUnit: pixelsPerInch,
                          unitLabel: 'inch',
                          themeColor: isDark ? Colors.white30 : Colors.black12,
                          textColor: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),

                    // Draggable Caliper Guide (Horizontal bar)
                    Positioned(
                      top: _sliderPos - 1,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            _sliderPos += details.delta.dy;
                            if (_sliderPos < 0) _sliderPos = 0;
                            if (_sliderPos > maxH) _sliderPos = maxH;
                          });
                        },
                        child: Container(
                          height: 3,
                          color: theme.primaryColor,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.controlRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.unfold_more_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Measurement Readout Bento Card
            BentoCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        provider.translate('SENTIMETER', 'CENTIMETER'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${cmValue.toStringAsFixed(2)} cm",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _useCm
                              ? theme.primaryColor
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 40, thickness: 1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        provider.translate('INCI', 'INCHES'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${inchValue.toStringAsFixed(2)} in",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: !_useCm
                              ? theme.primaryColor
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class RulerScalePainter extends CustomPainter {
  final bool isLeft;
  final double pixelsPerUnit;
  final String unitLabel;
  final Color themeColor;
  final Color textColor;

  RulerScalePainter({
    required this.isLeft,
    required this.pixelsPerUnit,
    required this.unitLabel,
    required this.themeColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 1.5;

    final borderPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.0;

    // Draw long vertical line bounding the scale
    final lineX = isLeft ? size.width : 0.0;
    canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), borderPaint);

    double y = 0.0;
    int tickCount = 0;

    // We draw sub-units (mm for cm, 1/8 inch for inches)
    final subDivisions = isLeft ? 10 : 8;
    final step = pixelsPerUnit / subDivisions;

    while (y < size.height) {
      final isMajor = tickCount % subDivisions == 0;
      final isHalf = isLeft ? (tickCount % 5 == 0) : (tickCount % 4 == 0);

      double tickLength;
      if (isMajor) {
        tickLength = 32.0;
      } else if (isHalf) {
        tickLength = 22.0;
      } else {
        tickLength = 14.0;
      }

      final startX = isLeft ? 0.0 : size.width;
      final endX = isLeft ? tickLength : size.width - tickLength;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);

      // Label major ticks
      if (isMajor && y > 0) {
        final unitVal = tickCount ~/ subDivisions;
        final textSpan = TextSpan(
          text: "$unitVal",
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final labelX = isLeft
            ? tickLength + 5
            : size.width - tickLength - textPainter.width - 5;
        textPainter.paint(canvas, Offset(labelX, y - textPainter.height / 2));
      }

      y += step;
      tickCount++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

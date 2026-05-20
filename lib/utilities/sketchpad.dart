import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bento_card.dart';

class SketchpadWidget extends StatefulWidget {
  const SketchpadWidget({super.key});

  @override
  State<SketchpadWidget> createState() => _SketchpadWidgetState();
}

class _SketchpadWidgetState extends State<SketchpadWidget> {
  final List<DrawingStroke?> _strokes = [];
  Color _selectedColor = AppTheme.primaryColor;
  double _strokeWidth = 5.0;
  bool _isEraser = false;

  final List<Color> _colors = [
    AppTheme.primaryColor,
    AppTheme.secondaryColor,
    AppTheme.tertiaryColor,
    AppTheme.neutralColor,
    Colors.white,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Controls Bento Card
        BentoCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Brush size & Mode buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Undo & Clear Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo_rounded),
                        onPressed: _strokes.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  // Remove last stroke (up to last null marker)
                                  if (_strokes.isNotEmpty) {
                                    // Remove trailing nulls
                                    while (_strokes.isNotEmpty &&
                                        _strokes.last == null) {
                                      _strokes.removeLast();
                                    }
                                    // Remove points of last stroke
                                    while (_strokes.isNotEmpty &&
                                        _strokes.last != null) {
                                      _strokes.removeLast();
                                    }
                                    // Remove separator if any
                                    if (_strokes.isNotEmpty &&
                                        _strokes.last == null) {
                                      _strokes.removeLast();
                                    }
                                  }
                                });
                              },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_sweep_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _strokes.clear();
                          });
                        },
                      ),
                    ],
                  ),

                  // Size Indicator & Slider
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.brush_rounded,
                            size: 16,
                            color: _isEraser ? Colors.grey : _selectedColor,
                          ),
                          Expanded(
                            child: Slider(
                              value: _strokeWidth,
                              min: 1.0,
                              max: 20.0,
                              activeColor: _isEraser
                                  ? Colors.grey
                                  : _selectedColor,
                              onChanged: (val) =>
                                  setState(() => _strokeWidth = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Eraser Toggle
                  IconButton(
                    icon: Icon(
                      Icons.cleaning_services_rounded,
                      color: _isEraser ? theme.primaryColor : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEraser = !_isEraser;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Colors list
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = _selectedColor == color && !_isEraser;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                          _isEraser = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : (isDark ? Colors.white24 : Colors.black12),
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Drawing Board
        Expanded(
          child: BentoCard(
            padding: EdgeInsets.zero,
            color: AppTheme.cardAltColor(isDark),
            child: GestureDetector(
              onPanStart: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition = renderBox.globalToLocal(
                  details.globalPosition,
                );
                // Adjust for upper header height offset
                setState(() {
                  _strokes.add(
                    DrawingStroke(
                      point: localPosition,
                      color: _isEraser
                          ? AppTheme.cardAltColor(isDark)
                          : _selectedColor,
                      width: _strokeWidth,
                    ),
                  );
                });
              },
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition = renderBox.globalToLocal(
                  details.globalPosition,
                );
                setState(() {
                  _strokes.add(
                    DrawingStroke(
                      point: localPosition,
                      color: _isEraser
                          ? AppTheme.cardAltColor(isDark)
                          : _selectedColor,
                      width: _strokeWidth,
                    ),
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _strokes.add(null);
                });
              },
              child: CustomPaint(
                painter: SketchpadPainter(_strokes),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DrawingStroke {
  final Offset point;
  final Color color;
  final double width;

  DrawingStroke({
    required this.point,
    required this.color,
    required this.width,
  });
}

class SketchpadPainter extends CustomPainter {
  final List<DrawingStroke?> strokes;

  SketchpadPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length - 1; i++) {
      if (strokes[i] != null && strokes[i + 1] != null) {
        final paint = Paint()
          ..color = strokes[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokes[i]!.width;

        canvas.drawLine(strokes[i]!.point, strokes[i + 1]!.point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BentoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final int gridWidth;
  final int gridHeight;

  const BentoCard({
    Key? key,
    required this.child,
    this.onTap,
    this.color,
    this.borderColor,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.gridWidth = 1,
    this.gridHeight = 1,
  }) : super(key: key);

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = widget.color ?? AppTheme.cardColor(isDark);
    final hoverBg = isDark ? AppTheme.darkCardAlt : AppTheme.lightCardAlt;
    final border = widget.borderColor ?? AppTheme.borderColor(isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
        onTapUp: (_) => widget.onTap != null ? _controller.reverse() : null,
        onTapCancel: () => widget.onTap != null ? _controller.reverse() : null,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: (_isHovering && widget.onTap != null) ? hoverBg : bgColor,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: (_isHovering && widget.onTap != null) ? theme.primaryColor : border,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Padding(padding: widget.padding, child: widget.child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

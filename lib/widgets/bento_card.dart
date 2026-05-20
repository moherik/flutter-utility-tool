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
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderColor,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.gridWidth = 1,
    this.gridHeight = 1,
  });

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
    final hoverBg = AppTheme.cardAltColor(isDark);
    final border = widget.borderColor ?? AppTheme.borderColor(isDark);
    final isInteractive = widget.onTap != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => isInteractive ? _controller.forward() : null,
        onTapUp: (_) => isInteractive ? _controller.reverse() : null,
        onTapCancel: () => isInteractive ? _controller.reverse() : null,
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
                  color: (_isHovering && isInteractive) ? hoverBg : bgColor,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(
                    color: (_isHovering && isInteractive)
                        ? theme.colorScheme.primary.withValues(alpha: 0.4)
                        : border,
                  ),
                  boxShadow: AppTheme.cardShadow(isDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  child: Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

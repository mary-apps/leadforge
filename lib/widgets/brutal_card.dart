import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';

/// A reusable neo-brutalist card with press animation.
class BrutalCard extends StatefulWidget {
  const BrutalCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.primary,
    this.shadowOffsetX = 3,
    this.shadowOffsetY = 3,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppColors.brutalRadius,
  });

  final Widget child;
  final Color borderColor;
  final double shadowOffsetX;
  final double shadowOffsetY;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  State<BrutalCard> createState() => _BrutalCardState();
}

class _BrutalCardState extends State<BrutalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<Offset>(
      begin: Offset(widget.shadowOffsetX, widget.shadowOffsetY),
      end: const Offset(1, 1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
    Haptics.light();
    widget.onTap!();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor,
                  width: AppColors.brutalBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.borderColor.withValues(alpha: 0.4),
                    offset: _shadowAnimation.value,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

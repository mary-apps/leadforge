import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';

/// A clean card with optional press animation.
class BrutalCard extends StatefulWidget {
  const BrutalCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.showBorder = false,
    // Kept for backward compat but ignored
    this.borderColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final Color? borderColor;
  final double? shadowOffsetX;
  final double? shadowOffsetY;
  final double? borderRadius;

  @override
  State<BrutalCard> createState() => _BrutalCardState();
}

class _BrutalCardState extends State<BrutalCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _pressed = false);
    Haptics.light();
    widget.onTap!();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusXL),
            border: widget.showBorder
                ? Border.all(color: AppColors.border, width: 1)
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

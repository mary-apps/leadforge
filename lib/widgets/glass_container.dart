import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A premium glassmorphic container with backdrop blur and subtle border.
/// Use for cards, overlays, and premium surface elements.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 14.0,
    this.blur = 20.0,
    this.opacity = 0.6,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.border,
                width: 0.5,
              ),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A container with a subtle gradient border that gives a premium glow effect.
/// Use for highlighting important cards like stats, CTAs, etc.
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? gradientColors;
  final Color? backgroundColor;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 14.0,
    this.borderWidth = 1.0,
    this.gradientColors,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          AppColors.primary.withValues(alpha: 0.4),
          AppColors.primary.withValues(alpha: 0.0),
          AppColors.primary.withValues(alpha: 0.15),
        ];

    return Container(
      margin: margin,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

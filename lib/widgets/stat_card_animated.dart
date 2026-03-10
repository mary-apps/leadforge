import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

/// Animated stat card with counting numbers
class StatCardAnimated extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final int index; // For stagger animation
  final bool isBrutal;
  final String? trend;

  const StatCardAnimated({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.index = 0,
    this.isBrutal = false,
    this.trend,
  });

  @override
  State<StatCardAnimated> createState() => _StatCardAnimatedState();
}

class _StatCardAnimatedState extends State<StatCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _counterAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _counterAnimation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start after stagger delay
    Future.delayed(
      Duration(milliseconds: 100 * widget.index),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isBrutal ? widget.color : AppColors.border,
          width: widget.isBrutal ? 2 : 1,
        ),
        boxShadow: widget.isBrutal
            ? [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, color: widget.color, size: 24),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _counterAnimation,
            builder: (context, child) {
              return Text(
                _counterAnimation.value.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          if (widget.trend != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.trend!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.trend!.startsWith('-')
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            widget.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: (100 * widget.index).ms,
          duration: 300.ms,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: (100 * widget.index).ms,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

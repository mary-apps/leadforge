import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

/// Animated stat card with counting numbers and entrance animation.
class StatCardAnimated extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final int index;
  final String? trend;

  /// Kept for backward compat — ignored.
  final bool isBrutal;

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _counterAnimation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

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
    return Padding(
      padding: const EdgeInsets.all(4),
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
                style: AppTypography.numberLarge,
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
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
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

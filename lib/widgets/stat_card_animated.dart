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
  
  const StatCardAnimated({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.index = 0,
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
    final width = (MediaQuery.of(context).size.width - 44) / 2;
    
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, color: widget.color, size: 32),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _counterAnimation,
            builder: (context, child) {
              return Text(
                _counterAnimation.value.toString(),
                style: AppTypography.headlineLarge.copyWith(
                  color: widget.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: AppTypography.bodyMedium.copyWith(
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

import 'package:flutter/cupertino.dart';
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
    final resolvedSurface = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final resolvedTertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: resolvedSurface,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, color: widget.color, size: 16),
          ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (widget.trend!.startsWith('-')
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemGreen)
                    .resolveFrom(context)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.trend!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: (widget.trend!.startsWith('-')
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemGreen)
                      .resolveFrom(context),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: resolvedTertiary,
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

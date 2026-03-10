import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';

/// Conic gradient ring score gauge with animated fill.
class AnimatedScoreGauge extends StatefulWidget {
  final int score;
  final VoidCallback? onComplete;

  const AnimatedScoreGauge({
    super.key,
    required this.score,
    this.onComplete,
  });

  @override
  State<AnimatedScoreGauge> createState() => _AnimatedScoreGaugeState();
}

class _AnimatedScoreGaugeState extends State<AnimatedScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int get _currentScore => (widget.score * _animation.value).round();

  Color get _scoreColor => AppColors.scoreColor(_currentScore);

  String get _statusLabel {
    final s = _currentScore;
    if (s < 40) return 'Needs Work';
    if (s <= 70) return 'Decent';
    return 'Strong';
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward().then((_) {
          Haptics.medium();
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final color = _scoreColor;
        final progress = (widget.score / 100.0) * _animation.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_currentScore',
                        style: AppTypography.scoreLarge.copyWith(color: color),
                      ),
                      const Text(
                        'SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusLabel,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 8.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc with gradient
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2;

      final rect = Rect.fromCircle(center: center, radius: radius);

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            color.withValues(alpha: 0.4),
            color,
          ],
          stops: const [0.0, 1.0],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

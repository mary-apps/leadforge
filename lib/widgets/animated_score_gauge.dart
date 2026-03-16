import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';

import '../utils/haptics.dart';

/// Conic gradient ring score gauge with animated fill and confetti celebration.
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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ConfettiController _confettiController;
  bool _completed = false;

  int get _currentScore => (widget.score * _animation.value).round();

  Color _scoreColor(BuildContext context) {
    final s = _currentScore;
    if (s < 40) return CupertinoColors.systemRed.resolveFrom(context);
    if (s <= 70) return CupertinoColors.systemOrange.resolveFrom(context);
    return CupertinoColors.systemGreen.resolveFrom(context);
  }

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

    // Pulse animation for the score number on completion
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutCubic,
    ));

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1500),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward().then((_) {
          if (!mounted) return;
          setState(() => _completed = true);
          Haptics.heavy();
          _pulseController.forward();
          _confettiController.play();
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);
    final resolvedPrimary = CupertinoColors.systemBlue.resolveFrom(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final color = _scoreColor(context);
        final progress = (widget.score / 100.0) * _animation.value;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: progress,
                      color: color,
                      trackColor: CupertinoColors.tertiarySystemGroupedBackground.resolveFrom(context),
                      tickColor: CupertinoColors.separator.resolveFrom(context),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              );
                            },
                            child: Text(
                              '$_currentScore',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.37,
                                color: color,
                              ),
                            ),
                          ),
                          Text(
                            'SCORE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: resolvedTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: _completed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: _completed ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Confetti overlay
            Positioned(
              top: 0,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
                maxBlastForce: 15,
                minBlastForce: 5,
                emissionFrequency: 0.0,
                gravity: 0.2,
                shouldLoop: false,
                colors: [
                  color,
                  color.withValues(alpha: 0.6),
                  resolvedPrimary,
                  resolvedPrimary.withValues(alpha: 0.5),
                ],
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
  final Color trackColor;
  final Color tickColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = trackColor
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

      // End dot at the terminus of the arc with glow
      final endAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dotX, dotY), 7, glowPaint);

      // Core dot
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    }

    // Tick marks at 25%, 50%, 75%
    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final pct in [0.25, 0.50, 0.75]) {
      final angle = -math.pi / 2 + 2 * math.pi * pct;
      final innerX = center.dx + (radius - 4) * math.cos(angle);
      final innerY = center.dy + (radius - 4) * math.sin(angle);
      final outerX = center.dx + (radius + 4) * math.cos(angle);
      final outerY = center.dy + (radius + 4) * math.sin(angle);
      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

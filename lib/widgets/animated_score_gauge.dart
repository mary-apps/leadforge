import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';

/// Premium animated score gauge with spring physics
class AnimatedScoreGauge extends StatefulWidget {
  final int score;
  final double size;
  final VoidCallback? onComplete;
  
  const AnimatedScoreGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.onComplete,
  });

  @override
  State<AnimatedScoreGauge> createState() => _AnimatedScoreGaugeState();
}

class _AnimatedScoreGaugeState extends State<AnimatedScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _arcAnimation;
  late Animation<int> _numberAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Arc animation with spring curve
    _arcAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    // Number counting animation
    _numberAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    // Start animation after small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward().then((_) {
          Haptics.medium(); // Haptic on complete
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
    final color = AppColors.scoreColor(widget.score);
    
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _AnimatedGaugePainter(
                score: widget.score,
                progress: _arcAnimation.value,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated number
                    Text(
                      _numberAnimation.value.toString(),
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: widget.size * 0.25,
                        fontFamily: 'SF Mono',
                      ),
                    ),
                    // Label with fade in
                    Opacity(
                      opacity: _controller.value.clamp(0.0, 1.0),
                      child: Text(
                        _getScoreLabel(widget.score),
                        style: AppTypography.bodyMedium.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .scale(
          delay: 100.ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 200.ms);
  }
  
  String _getScoreLabel(int score) {
    if (score < 40) return 'Poor';
    if (score < 70) return 'Fair';
    return 'Good';
  }
}

class _AnimatedGaugePainter extends CustomPainter {
  final int score;
  final double progress;
  final Color color;
  
  _AnimatedGaugePainter({
    required this.score,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );
    
    // Animated score arc
    if (progress > 0) {
      final scorePaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.6), color],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      
      final sweepAngle = (score / 100) * pi * 1.5 * progress;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi * 0.75,
        sweepAngle,
        false,
        scorePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

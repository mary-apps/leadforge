import 'dart:math';

import 'package:flutter/material.dart';

import '../config/theme.dart';

class ScoreGauge extends StatelessWidget {
  final int score;
  final double size;
  
  const ScoreGauge({
    super.key,
    required this.score,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GaugePainter(
            score: score,
            color: color,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score.toString(),
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: size * 0.25,
                    fontFamily: 'SF Mono',
                  ),
                ),
                Text(
                  _getScoreLabel(score),
                  style: AppTypography.bodyMedium.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getScoreLabel(int score) {
    if (score < 40) return 'Poor';
    if (score < 70) return 'Fair';
    return 'Good';
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;
  
  _GaugePainter({
    required this.score,
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
    
    // Score arc
    final scorePaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.5), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (score / 100) * pi * 1.5;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

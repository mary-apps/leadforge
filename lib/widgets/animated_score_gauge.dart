import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';
import 'brutal_card.dart';

/// Segmented brutal-style score gauge
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

  int get _currentScore =>
      (widget.score * _animation.value).round();

  int get _filledSegments =>
      (_currentScore / 20).ceil().clamp(0, 5);

  Color get _scoreColor {
    final s = _currentScore;
    if (s < 40) return AppColors.danger;
    if (s <= 70) return AppColors.warning;
    return AppColors.success;
  }

  String get _statusLabel {
    final s = _currentScore;
    if (s < 40) return 'NEEDS WORK';
    if (s <= 70) return 'DECENT';
    return 'STRONG';
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
        return BrutalCard(
          borderColor: color,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('DIGITAL SCORE', style: AppTypography.labelBrutal),
              const SizedBox(height: 8),
              Text(
                '$_currentScore',
                style: AppTypography.scoreLarge.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                _statusLabel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              // Segmented bar — 5 segments
              Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i < _filledSegments
                            ? color
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

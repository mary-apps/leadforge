import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/haptics.dart';

/// A neo-brutalist button with press animation, loading state, and icon support.
class BrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final IconData? icon;

  BrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.primary,
    this.isLoading = false,
    this.icon,
  });

  BrutalButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.secondary,
    this.isLoading = false,
    this.icon,
  });

  BrutalButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.success,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shadowAnimation;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<Offset>(
      begin: AppColors.brutalShadowOffset,
      end: AppColors.brutalShadowOffsetPressed,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isDisabled) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_isDisabled) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (_isDisabled) return;
    _controller.reverse();
  }

  void _onTap() {
    if (_isDisabled) return;
    Haptics.light();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: Opacity(
              opacity: _isDisabled ? 0.5 : 1.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.color,
                  border: Border.all(
                    color: widget.color,
                    width: AppColors.brutalBorderWidth,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppColors.brutalButtonRadius),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      offset: _shadowAnimation.value,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 16,
                        color: AppColors.background,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: AppTypography.buttonBrutal,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

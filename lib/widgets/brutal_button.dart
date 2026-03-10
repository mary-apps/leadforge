import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/haptics.dart';

enum _ButtonVariant { primary, secondary, success, danger, ghost }

/// A clean modern button with press animation, loading state, and icon support.
class BrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool compact;
  final _ButtonVariant _variant;

  const BrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.primary;

  const BrutalButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.secondary;

  const BrutalButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.success;

  const BrutalButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.danger;

  const BrutalButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.compact = false,
  }) : _variant = _ButtonVariant.ghost;

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  Color get _backgroundColor {
    switch (widget._variant) {
      case _ButtonVariant.primary:
        return AppColors.primary;
      case _ButtonVariant.secondary:
        return AppColors.surface;
      case _ButtonVariant.success:
        return AppColors.success.withValues(alpha: 0.15);
      case _ButtonVariant.danger:
        return AppColors.danger.withValues(alpha: 0.15);
      case _ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (widget._variant) {
      case _ButtonVariant.primary:
        return AppColors.background;
      case _ButtonVariant.secondary:
        return AppColors.textPrimary;
      case _ButtonVariant.success:
        return AppColors.success;
      case _ButtonVariant.danger:
        return AppColors.danger;
      case _ButtonVariant.ghost:
        return AppColors.textPrimary;
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_isDisabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (_isDisabled) return;
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (_isDisabled) return;
    setState(() => _pressed = false);
  }

  void _onTap() {
    if (_isDisabled) return;
    Haptics.light();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final vPad = widget.compact ? 8.0 : 12.0;
    final hPad = widget.compact ? 16.0 : 24.0;
    final minH = widget.compact ? 36.0 : 44.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedScale(
        scale: _pressed && !_isDisabled ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isDisabled ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: vPad,
              ),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(AppColors.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_foregroundColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 18,
                      color: _foregroundColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.button.copyWith(
                      color: _foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

enum _ButtonVariant { primary, secondary, success, danger, ghost }

class BrutalButton extends StatelessWidget {
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

  Color _color(BuildContext context) {
    return switch (_variant) {
      _ButtonVariant.primary => CupertinoColors.systemBlue.resolveFrom(context),
      _ButtonVariant.secondary => CupertinoColors.secondaryLabel.resolveFrom(context),
      _ButtonVariant.success => CupertinoColors.systemGreen.resolveFrom(context),
      _ButtonVariant.danger => CupertinoColors.systemRed.resolveFrom(context),
      _ButtonVariant.ghost => CupertinoColors.systemBlue.resolveFrom(context),
    };
  }

  bool get _isFilled =>
      _variant == _ButtonVariant.primary ||
      _variant == _ButtonVariant.success ||
      _variant == _ButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final child = isLoading
        ? const CupertinoActivityIndicator()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    if (_isFilled) {
      return SizedBox(
        width: compact ? null : double.infinity,
        child: CupertinoButton(
          color: color,
          padding: EdgeInsets.symmetric(
            vertical: compact ? 8 : 14,
            horizontal: compact ? 16 : 24,
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: compact ? null : double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 14,
          horizontal: compact ? 16 : 24,
        ),
        onPressed: isLoading ? null : onPressed,
        child: DefaultTextStyle(
          style: TextStyle(color: color),
          child: IconTheme(
            data: IconThemeData(color: color),
            child: child,
          ),
        ),
      ),
    );
  }
}

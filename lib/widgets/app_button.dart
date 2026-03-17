import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool compact;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: compact ? null : double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 10 : 14,
          horizontal: compact ? 20 : 0,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor(context),
          border: variant == AppButtonVariant.secondary
              ? Border.all(color: CupertinoDynamicColor.resolve(AppColors.border, context))
              : null,
          borderRadius: BorderRadius.circular(AppColors.radiusL),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(
                    color: _textColor(context),
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.button(context).copyWith(
                    color: _textColor(context),
                  ),
                ),
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return CupertinoDynamicColor.resolve(AppColors.accent, context);
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return const Color(0x00000000);
    }
  }

  Color _textColor(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return CupertinoDynamicColor.resolve(AppColors.chipActiveFg, context);
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return CupertinoDynamicColor.resolve(AppColors.accent, context);
    }
  }
}

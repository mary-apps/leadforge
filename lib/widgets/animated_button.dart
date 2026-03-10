import 'package:flutter/material.dart';

import '../utils/haptics.dart';

/// Button with scale animation and haptic feedback
@Deprecated('Use BrutalButton instead')
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enabled;
  
  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.enabled = true,
  });
  
  factory AnimatedButton.primary({
    required Widget child,
    VoidCallback? onPressed,
    bool enabled = true,
  }) =>
      AnimatedButton(
        onPressed: onPressed,
        enabled: enabled,
        child: child,
      );
  
  factory AnimatedButton.secondary({
    required Widget child,
    VoidCallback? onPressed,
    bool enabled = true,
  }) =>
      AnimatedButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        enabled: enabled,
        child: child,
      );

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.forward();
      Haptics.light();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _controller.reverse();
    }
  }
  
  void _handleTapCancel() {
    _controller.reverse();
  }
  
  void _handleTap() {
    if (widget.enabled && widget.onPressed != null) {
      Haptics.medium();
      widget.onPressed!();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: Container(
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.backgroundColor ??
                  Theme.of(context).colorScheme.primary,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.foregroundColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Text',
              ),
              child: Center(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

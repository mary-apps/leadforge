import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';

class AppBottomNav extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  static const _tabs = [
    (
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    (
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Pipeline',
    ),
    (
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
      label: 'Scout',
    ),
    (
      icon: CupertinoIcons.bubble_left,
      activeIcon: CupertinoIcons.bubble_left_fill,
      label: 'Activity',
    ),
    (
      icon: CupertinoIcons.gear_alt,
      activeIcon: CupertinoIcons.gear_alt_fill,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor =
        CupertinoDynamicColor.resolve(AppColors.background, context);
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: navigationShell),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.85),
                  border: Border(
                    top: BorderSide(color: dividerColor, width: 0.5),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (int i = 0; i < _tabs.length; i++)
                          _NavItem(
                            icon: _tabs[i].icon,
                            activeIcon: _tabs[i].activeIcon,
                            label: _tabs[i].label,
                            isActive: i == navigationShell.currentIndex,
                            onTap: () => navigationShell.goBranch(
                              i,
                              initialLocation:
                                  i == navigationShell.currentIndex,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _springAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _triggerSpring();
    }
  }

  void _triggerSpring() {
    _springAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.82)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.82, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_springController);
    _springController.forward(from: 0);
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final inactiveColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final pillAlpha = brightness == Brightness.dark ? 0.16 : 0.12;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: Duration(milliseconds: _pressed ? 80 : 300),
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: AnimatedBuilder(
          animation: _springAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _springAnimation.value,
              child: child,
            );
          },
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isActive ? 18 : AppConstants.navPillH,
                    vertical: AppConstants.navPillV,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? activeColor.withValues(alpha: pillAlpha)
                        : const Color(0x00000000),
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusXL),
                  ),
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: widget.isActive ? activeColor : inactiveColor,
                    ),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, color, _) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Icon(
                        widget.isActive ? widget.activeIcon : widget.icon,
                        key: ValueKey(widget.isActive),
                        size: AppConstants.navIconSize,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedOpacity(
                  opacity: widget.isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: widget.isActive
                        ? Offset.zero
                        : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: activeColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

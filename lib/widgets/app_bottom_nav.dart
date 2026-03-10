import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../providers/businesses_provider.dart';
import '../utils/haptics.dart';

class AppBottomNav extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live data for badge counts
    final businessesAsync = ref.watch(businessesProvider);
    final pipelineCount = businessesAsync.valueOrNull?.length ?? 0;
    final recentCount = businessesAsync.valueOrNull
            ?.where((b) =>
                DateTime.now().difference(b.updatedAt ?? b.createdAt).inHours <
                24)
            .length ??
        0;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: _ScoutFAB(
        isSelected: navigationShell.currentIndex == 2,
        onTap: () {
          Haptics.medium();
          navigationShell.goBranch(2);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        pipelineBadge: pipelineCount,
        activityBadge: recentCount,
        onTap: (index) {
          Haptics.light();
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scout FAB — scale + rotation on press, no glow
// ---------------------------------------------------------------------------

class _ScoutFAB extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _ScoutFAB({
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ScoutFAB> createState() => _ScoutFABState();
}

class _ScoutFABState extends State<_ScoutFAB> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedRotation(
        turns: _pressed ? 15 / 360 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radiusXL + 2),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppColors.radiusXL),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.background,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glassmorphic bottom bar with sliding indicator
// ---------------------------------------------------------------------------

class _BottomBar extends StatefulWidget {
  final int currentIndex;
  final int pipelineBadge;
  final int activityBadge;
  final ValueChanged<int> onTap;

  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
    this.pipelineBadge = 0,
    this.activityBadge = 0,
  });

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  // Maps the 5-branch index (0,1,2,3,4) to a slot position (0,1, gap, 2,3)
  // for the 4 visible nav items. Index 2 (FAB) has no slot.
  static const _slotCount = 5; // total columns including center gap

  /// Returns the fractional horizontal position [0..1] for the indicator.
  double _indicatorPosition(int index) {
    // Slot layout:  0  |  1  |  gap  |  3  |  4
    // Each slot is 1/_slotCount of the bar width.
    // Center of each slot:
    switch (index) {
      case 0:
        return 0.5 / _slotCount; // center of slot 0
      case 1:
        return 1.5 / _slotCount; // center of slot 1
      case 2:
        return 2.5 / _slotCount; // center (FAB) – shouldn't show indicator
      case 3:
        return 3.5 / _slotCount; // center of slot 3
      case 4:
        return 4.5 / _slotCount; // center of slot 4
      default:
        return 0.5 / _slotCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showIndicator = widget.currentIndex != 2;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: SizedBox(
                height: 52,
                child: Stack(
                  children: [
                    // ── Sliding indicator pill ──
                    if (showIndicator)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const pillWidth = 20.0;
                          const pillHeight = 4.0;
                          final totalWidth = constraints.maxWidth;
                          final centerX =
                              _indicatorPosition(widget.currentIndex) *
                                  totalWidth;
                          final left = centerX - pillWidth / 2;

                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            left: left,
                            top: 0,
                            child: Container(
                              width: pillWidth,
                              height: pillHeight,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),

                    // ── Nav items row ──
                    Positioned.fill(
                      top: 6, // leave room for pill
                      child: Row(
                        children: [
                          _NavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            isSelected: widget.currentIndex == 0,
                            onTap: () => widget.onTap(0),
                          ),
                          _NavItem(
                            icon: Icons.view_kanban_rounded,
                            label: 'Pipeline',
                            isSelected: widget.currentIndex == 1,
                            badge: widget.pipelineBadge,
                            onTap: () => widget.onTap(1),
                          ),
                          const SizedBox(width: 64), // Gap for FAB
                          _NavItem(
                            icon: Icons.history_rounded,
                            label: 'Activity',
                            isSelected: widget.currentIndex == 3,
                            badge: widget.activityBadge,
                            onTap: () => widget.onTap(3),
                          ),
                          _NavItem(
                            icon: Icons.settings_rounded,
                            label: 'Settings',
                            isSelected: widget.currentIndex == 4,
                            onTap: () => widget.onTap(4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual nav item — spring scale icon + slide-up label
// ---------------------------------------------------------------------------

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _springScale;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _springScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
    ]).animate(_springController);
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _springController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with spring scale + badge
            AnimatedBuilder(
              animation: _springScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isSelected ? _springScale.value : 1.0,
                  child: child,
                );
              },
              child: SizedBox(
                width: 28,
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: color,
                      ),
                    ),
                    if (widget.badge > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            constraints: const BoxConstraints(minWidth: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.badge > 99 ? '99+' : widget.badge.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.background,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Label: slide up + fade in when active
            SizedBox(
              height: 14,
              child: AnimatedSlide(
                offset: widget.isSelected
                    ? Offset.zero
                    : const Offset(0, 0.4),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

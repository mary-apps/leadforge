import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';

import '../config/theme.dart';
import '../utils/breakpoints.dart';

/// Tab destination definition shared with [AppBottomNav].
typedef _Tab = ({IconData icon, IconData activeIcon, String label});

const List<_Tab> _tabs = [
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

/// Cupertino-styled sidebar for medium (rail) and expanded (full) layouts.
///
/// On **expanded** (>= 1024 px) the sidebar is 220 px wide and shows
/// icons + labels. On **medium** (600-1024 px) it collapses to a 72 px
/// icon-only rail.
///
/// On macOS an extra 52 px of top padding is added so the title bar drag
/// area is not occluded.
class AppSidebarNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppSidebarNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double _expandedWidth = 220;
  static const double _railWidth = 72;
  static const double _macTitleBarPadding = 52;

  @override
  Widget build(BuildContext context) {
    final isRail = formFactorOf(context) == FormFactor.medium;
    final width = isRail ? _railWidth : _expandedWidth;

    final bgColor =
        CupertinoDynamicColor.resolve(AppColors.surface, context);
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    final bool isMacOS = Platform.isMacOS;
    final topPadding =
        MediaQuery.paddingOf(context).top + (isMacOS ? _macTitleBarPadding : 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        right: false,
        bottom: true,
        child: Column(
          crossAxisAlignment:
              isRail ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPadding),
            // Title
            if (!isRail)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'LeadForge',
                  style: AppTypography.headlineLarge(context),
                ),
              )
            else
              const SizedBox(height: 12),
            const SizedBox(height: 8),
            // Tab items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isRail ? 8 : 12,
                ),
                children: [
                  for (int i = 0; i < _tabs.length; i++)
                    _SidebarItem(
                      icon: _tabs[i].icon,
                      activeIcon: _tabs[i].activeIcon,
                      label: _tabs[i].label,
                      isActive: i == currentIndex,
                      isRail: isRail,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isRail;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isRail,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final inactiveColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final hoverAlpha = brightness == Brightness.dark ? 0.08 : 0.06;
    final activeAlpha = brightness == Brightness.dark ? 0.14 : 0.10;

    final Color iconColor = widget.isActive ? accentColor : inactiveColor;
    final Color labelColor = widget.isActive
        ? accentColor
        : CupertinoDynamicColor.resolve(AppColors.textSecondary, context);

    final Color bgColor = widget.isActive
        ? accentColor.withValues(alpha: activeAlpha)
        : _hovered
            ? accentColor.withValues(alpha: hoverAlpha)
            : const Color(0x00000000);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isRail ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            child: widget.isRail ? _buildRailContent(iconColor) : _buildFullContent(iconColor, labelColor),
          ),
        ),
      ),
    );
  }

  Widget _buildRailContent(Color iconColor) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          widget.isActive ? widget.activeIcon : widget.icon,
          key: ValueKey(widget.isActive),
          size: 22,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildFullContent(Color iconColor, Color labelColor) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            widget.isActive ? widget.activeIcon : widget.icon,
            key: ValueKey(widget.isActive),
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

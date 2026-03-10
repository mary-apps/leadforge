import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../utils/haptics.dart';

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: (index) {
          Haptics.light();
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}

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
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.background,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.background,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'HOME',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.view_kanban_rounded,
              label: 'PIPELINE',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 64), // Gap for FAB
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'MESSAGES',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.settings_rounded,
              label: 'SETTINGS',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

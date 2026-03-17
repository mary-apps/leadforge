import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';

class AppBottomNav extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final inactiveColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
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
                child: CupertinoTabBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  backgroundColor: const Color(0x00000000),
                  border: const Border(),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.house_fill),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.chart_bar_fill),
                      label: 'Pipeline',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.search),
                      label: 'Scout',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.bubble_left_fill),
                      label: 'Activity',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.gear),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

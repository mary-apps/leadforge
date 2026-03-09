import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';

class AppBottomNav extends StatelessWidget {
  final Widget child;
  
  const AppBottomNav({
    super.key,
    required this.child,
  });

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    if (location.startsWith('/scout')) return 0;
    if (location.startsWith('/pipeline')) return 1;
    if (location.startsWith('/dashboard')) return 2;
    if (location.startsWith('/settings')) return 3;
    
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.search,
                  label: 'Scout',
                  isSelected: _getCurrentIndex(context) == 0,
                  onTap: () => context.go('/scout'),
                ),
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Pipeline',
                  isSelected: _getCurrentIndex(context) == 1,
                  onTap: () => context.go('/pipeline'),
                ),
                _NavItem(
                  icon: Icons.analytics,
                  label: 'Dashboard',
                  isSelected: _getCurrentIndex(context) == 2,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: _getCurrentIndex(context) == 3,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

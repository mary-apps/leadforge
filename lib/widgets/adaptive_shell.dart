import 'package:flutter/cupertino.dart';

import '../utils/breakpoints.dart';
import 'app_bottom_nav.dart';
import 'app_sidebar_nav.dart';

/// Selects the appropriate navigation chrome based on screen width.
///
/// * **Compact** (< 600 px) -- bottom tab bar ([AppBottomNav])
/// * **Medium** (600-1024 px) -- narrow sidebar rail (icons only) + content
/// * **Expanded** (>= 1024 px) -- full sidebar (icons + labels) + content
class AdaptiveShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget child;

  const AdaptiveShell({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final factor = formFactorOf(context);

    if (factor == FormFactor.compact) {
      return AppBottomNav(
        currentIndex: currentIndex,
        onTap: onTap,
        child: child,
      );
    }

    // Medium or expanded: sidebar + content
    return CupertinoPageScaffold(
      child: Row(
        children: [
          AppSidebarNav(currentIndex: currentIndex, onTap: onTap),
          Expanded(child: child),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import 'brutal_button.dart';

/// A reusable empty-state widget with simple fade entrance.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor = AppColors.primary,
  });

  // ---------------------------------------------------------------------------
  // Factory constructors for common variants
  // ---------------------------------------------------------------------------

  factory EmptyState.noResults({Key? key, VoidCallback? onRetry}) {
    return EmptyState(
      key: key,
      icon: Icons.search_off_rounded,
      title: 'No results found',
      subtitle:
          'Try adjusting your search or filters to find what you\'re looking for.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
      iconColor: AppColors.secondary,
    );
  }

  factory EmptyState.noLeads({Key? key, VoidCallback? onScout}) {
    return EmptyState(
      key: key,
      icon: Icons.people_outline_rounded,
      title: 'No leads yet',
      subtitle:
          'Start scouting to discover and qualify new leads for your business.',
      actionLabel: onScout != null ? 'Scout Leads' : null,
      onAction: onScout,
      iconColor: AppColors.primary,
    );
  }

  factory EmptyState.firstTime({Key? key, VoidCallback? onStart}) {
    return EmptyState(
      key: key,
      icon: Icons.rocket_launch_rounded,
      title: 'Welcome to LeadForge',
      subtitle:
          'Your AI-powered lead generation journey starts here. Let\'s get going!',
      actionLabel: onStart != null ? 'Get Started' : null,
      onAction: onStart,
      iconColor: AppColors.primary,
    );
  }

  factory EmptyState.noMessages({Key? key, VoidCallback? onCompose}) {
    return EmptyState(
      key: key,
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No messages yet',
      subtitle: 'Compose a message to start engaging with your leads.',
      actionLabel: onCompose != null ? 'Compose' : null,
      onAction: onCompose,
      iconColor: AppColors.secondary,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: iconColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              BrutalButton(
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import 'brutal_button.dart';

/// A reusable empty-state widget with neo-brutalist styling and animated entrance.
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
      subtitle: 'Try adjusting your search or filters to find what you\'re looking for.',
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
      subtitle: 'Start scouting to discover and qualify new leads for your business.',
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
      subtitle: 'Your AI-powered lead generation journey starts here. Let\'s get going!',
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
            // Layered icon composition
            _buildIcon(),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 150.ms, duration: 400.ms),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 300.ms, duration: 400.ms),
            // Optional action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              BrutalButton(
                label: actionLabel!,
                onPressed: onAction!,
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 400.ms)
                  .slideY(
                      begin: 0.15, end: 0, delay: 450.ms, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: iconColor.withValues(alpha: 0.1),
          ),
          Icon(
            icon,
            size: 48,
            color: iconColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms);
  }
}

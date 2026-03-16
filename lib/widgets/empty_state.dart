import 'package:flutter/cupertino.dart';
import 'brutal_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.noResults({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.search,
        title: 'No results found',
        subtitle: 'Try adjusting your search or filters',
        actionLabel: onAction != null ? 'Clear Filters' : null,
        onAction: onAction,
      );

  factory EmptyState.noLeads({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.square_stack_3d_up,
        title: 'No leads yet',
        subtitle: 'Start scouting to find your first leads',
        actionLabel: onAction != null ? 'Start Scouting' : null,
        onAction: onAction,
      );

  factory EmptyState.firstTime({VoidCallback? onAction}) => EmptyState(
        icon: CupertinoIcons.sparkles,
        title: 'Welcome to LeadForge',
        subtitle: 'Search for businesses to get started',
        actionLabel: onAction != null ? 'Get Started' : null,
        onAction: onAction,
      );

  factory EmptyState.noMessages({VoidCallback? onAction}) => const EmptyState(
        icon: CupertinoIcons.bubble_left,
        title: 'No messages yet',
        subtitle: 'Activity will appear here as you engage with leads',
      );

  factory EmptyState.error({required VoidCallback onAction}) => EmptyState(
        icon: CupertinoIcons.exclamationmark_triangle,
        title: 'Something went wrong',
        subtitle: 'Please try again',
        actionLabel: 'Retry',
        onAction: onAction,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel.resolveFrom(context)), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              BrutalButton(label: actionLabel!, onPressed: onAction, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}

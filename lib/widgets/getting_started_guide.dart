import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

class GettingStartedGuide extends StatelessWidget {
  final VoidCallback onStartScouting;

  const GettingStartedGuide({super.key, required this.onStartScouting});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        icon: CupertinoIcons.search,
        title: 'Search for businesses',
        subtitle: 'Find leads in your niche and city',
        hasAction: true,
      ),
      (
        icon: CupertinoIcons.chart_bar,
        title: 'Analyze their website',
        subtitle: 'AI scores their online presence automatically',
        hasAction: false,
      ),
      (
        icon: CupertinoIcons.paperplane,
        title: 'Send your pitch',
        subtitle: 'Audit report + personalized outreach message',
        hasAction: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GET STARTED',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary, context),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                            AppColors.accent, context)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  child: Icon(
                    step.icon,
                    size: 20,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.accent, context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: AppTypography.titleMedium(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: AppTypography.bodyMedium(context).copyWith(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.textSecondary, context),
                        ),
                      ),
                      if (step.hasAction) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onStartScouting,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.accent, context),
                              borderRadius:
                                  BorderRadius.circular(AppColors.radiusL),
                            ),
                            child: Text(
                              'Start Scouting',
                              style: AppTypography.button(context).copyWith(
                                color: CupertinoDynamicColor.resolve(
                                    AppColors.chipActiveFg, context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: 100 * i))
              .fadeIn(duration: AppConstants.standardAnimation)
              .slideX(
                begin: -0.05,
                duration: AppConstants.standardAnimation +
                    const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic,
              );
        }),
      ],
    );
  }
}

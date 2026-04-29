import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';

// ---------------------------------------------------------------------------
// Private helper: a simple colored box used as a skeleton placeholder.
// ---------------------------------------------------------------------------

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.divider, context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ShimmerWrap -- wraps any child in a repeating shimmer animation using
// flutter_animate instead of the shimmer package.
// ---------------------------------------------------------------------------

class ShimmerWrap extends StatelessWidget {
  const ShimmerWrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final highlight =
        CupertinoDynamicColor.resolve(AppColors.border, context);

    return Animate(
      onPlay: (controller) => controller.repeat(),
      effects: [
        ShimmerEffect(
          duration: 1500.ms,
          color: highlight.withValues(alpha: 0.5),
        ),
      ],
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// DashboardSkeleton -- matches the dashboard screen layout.
// ---------------------------------------------------------------------------

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            60,
            AppConstants.pageHorizontal,
            AppConstants.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const _ShimmerBox(width: 140, height: 14),
              const SizedBox(height: 10),
              // Hero stat
              const _ShimmerBox(
                  width: 80, height: 48, borderRadius: AppColors.radiusM),
              const SizedBox(height: 4),
              const _ShimmerBox(width: 100, height: 12),
              const SizedBox(height: 12),

              // 3-column stat pills
              const Row(
                children: [
                  Expanded(
                    child: _ShimmerBox(
                        height: 40, borderRadius: AppColors.radiusL),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ShimmerBox(
                        height: 40, borderRadius: AppColors.radiusL),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ShimmerBox(
                        height: 40, borderRadius: AppColors.radiusL),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.itemGap),

              // Weekly activity graph
              const _ShimmerBox(
                  height: 160, borderRadius: AppColors.radiusXL),
              const SizedBox(height: 16),

              // Recent header
              const _ShimmerBox(width: 60, height: 12),
              const SizedBox(height: 12),

              // Featured first lead card (taller)
              const _ShimmerBox(
                  height: 72, borderRadius: AppColors.radiusL),
              const SizedBox(height: 12),

              // Compact remaining lead cards
              ...List.generate(
                  3,
                  (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: _ShimmerBox(
                            height: 48, borderRadius: AppColors.radiusL),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ActivitySkeleton -- matches the activity/messages screen layout.
// ---------------------------------------------------------------------------

class ActivitySkeleton extends StatelessWidget {
  const ActivitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pageHorizontal,
            vertical: 8,
          ),
          child: Column(
            children: List.generate(
                8,
                (index) => const Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.itemGap),
                      child: _ShimmerBox(
                          height: 60, borderRadius: AppColors.radiusL),
                    )),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BusinessDetailSkeleton -- matches the business detail screen layout.
// ---------------------------------------------------------------------------

class BusinessDetailSkeleton extends StatelessWidget {
  const BusinessDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row -- avatar + text
            const Row(
              children: [
                _ShimmerBox(width: 48, height: 48, borderRadius: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(width: 160, height: 16),
                      SizedBox(height: 6),
                      _ShimmerBox(width: 100, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact buttons -- 3 x 56px
            Row(
              children: List.generate(
                  3,
                  (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : 6,
                            right: index == 2 ? 0 : 6,
                          ),
                          child: const _ShimmerBox(
                              height: 56,
                              borderRadius: AppColors.radiusL),
                        ),
                      )),
            ),
            const SizedBox(height: 16),

            // Score card
            const _ShimmerBox(
                height: 140, borderRadius: AppColors.radiusL),
            const SizedBox(height: 16),

            // Breakdown
            const _ShimmerBox(
                height: 120, borderRadius: AppColors.radiusL),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SearchSkeleton -- 4 placeholder cards for search results.
// ---------------------------------------------------------------------------

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.pageHorizontal),
        child: Column(
          children: List.generate(
              4,
              (index) => Padding(
                    padding: EdgeInsets.only(
                        bottom: index < 3 ? AppConstants.itemGap : 0),
                    child: const _ShimmerBox(
                        height: 100, borderRadius: AppColors.radiusL),
                  )),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PipelineSkeleton -- 3 sections each with a label + card.
// ---------------------------------------------------------------------------

class PipelineSkeleton extends StatelessWidget {
  const PipelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                3,
                (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBox(width: 120, height: 16),
                          SizedBox(height: 8),
                          _ShimmerBox(
                              height: 80, borderRadius: AppColors.radiusL),
                        ],
                      ),
                    )),
          ),
        ),
      ),
    );
  }
}

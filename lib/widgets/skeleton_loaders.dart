import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ShimmerWrap — wraps any child in the standard shimmer animation.
// ---------------------------------------------------------------------------

class ShimmerWrap extends StatelessWidget {
  const ShimmerWrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// DashboardSkeleton — matches the dashboard screen layout.
// ---------------------------------------------------------------------------

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting area
            const _ShimmerBox(width: 200, height: 20),
            const SizedBox(height: 8),
            const _ShimmerBox(width: 140, height: 28),
            const SizedBox(height: 24),

            // Stats row — 3 cards
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == 2 ? 0 : 6,
                  ),
                  child: const _ShimmerBox(height: 90, borderRadius: 12),
                ),
              )),
            ),
            const SizedBox(height: 16),

            // Quick actions row — 3 cards
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == 2 ? 0 : 6,
                  ),
                  child: const _ShimmerBox(height: 60, borderRadius: 12),
                ),
              )),
            ),
            const SizedBox(height: 16),

            // Chart area
            const _ShimmerBox(height: 200, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BusinessDetailSkeleton — matches the business detail screen layout.
// ---------------------------------------------------------------------------

class BusinessDetailSkeleton extends StatelessWidget {
  const BusinessDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — avatar + text
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

            // Contact buttons — 3 x 56px
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == 2 ? 0 : 6,
                  ),
                  child: const _ShimmerBox(height: 56, borderRadius: 12),
                ),
              )),
            ),
            const SizedBox(height: 16),

            // Score card
            const _ShimmerBox(height: 140, borderRadius: 12),
            const SizedBox(height: 16),

            // Breakdown
            const _ShimmerBox(height: 120, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SearchSkeleton — 4 placeholder cards for search results.
// ---------------------------------------------------------------------------

class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(4, (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 3 ? 12 : 0),
            child: const _ShimmerBox(height: 100, borderRadius: 12),
          )),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PipelineSkeleton — 3 sections each with a label + card.
// ---------------------------------------------------------------------------

class PipelineSkeleton extends StatelessWidget {
  const PipelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: 120, height: 16),
                SizedBox(height: 8),
                _ShimmerBox(height: 80, borderRadius: 12),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

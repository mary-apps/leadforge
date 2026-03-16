import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../providers/businesses_provider.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/business_card.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/search_suggestions.dart';
import '../../widgets/brutal_button.dart';
import '../../widgets/forge_loader.dart';
import '../../widgets/shimmer_text.dart';
import '../../widgets/pulse_dot.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/haptics.dart';
import '../../utils/network.dart';

class ScoutScreen extends ConsumerStatefulWidget {
  const ScoutScreen({super.key});

  @override
  ConsumerState<ScoutScreen> createState() => _ScoutScreenState();
}

class _ScoutScreenState extends ConsumerState<ScoutScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounce;

  final List<String> _recentSearches = [];
  final List<String> _trendingSearches = [
    'dentists Los Angeles',
    'restaurants Miami',
    'plumbers Austin',
    'real estate agents NYC',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _focusNode.hasFocus && _searchController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    _debounce?.cancel();
    await _executeSearch(query);
  }

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty || _isSearching) return;

    setState(() {
      _showSuggestions = false;
      _hasSearched = true;
    });
    _focusNode.unfocus();

    final profileAsync = ref.read(profileNotifierProvider);
    final profile = profileAsync.value;

    if (profile != null && !profile.canSearch) {
      Haptics.heavy();
      _showPaywall();
      return;
    }

    setState(() => _isSearching = true);
    Haptics.medium();

    try {
      await ref.read(scoutResultsProvider.notifier).search(query);

      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) _recentSearches.removeLast();
        });
      }
    } catch (e) {
      if (e is LimitReachedException && mounted) {
        ref.read(scoutResultsProvider.notifier).clear();
        Haptics.heavy();
        _showPaywall();
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _showPaywall() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Search Limit Reached'),
        content: const Text(
          'You\'ve used all 5 free searches this month.\n\nUpgrade to Pro for unlimited searches, audits, demos, and AI outreach messages.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(scoutResultsProvider);

    return Scaffold(
      body: AuroraBackground(
        intensity: 0.7,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Floating SliverAppBar with title + search
              SliverAppBar(
                floating: true,
                snap: true,
                expandedHeight: 118,
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const GradientText(
                                text: 'Scout',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                                colors: [AppColors.primary, AppColors.primaryLight],
                              ),
                              GestureDetector(
                                onTap: () =>
                                    ref.read(businessesProvider.notifier).load(),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppColors.radiusL),
                                    border: Border.all(
                                        color: AppColors.border, width: 0.5),
                                  ),
                                  child: const Icon(Icons.refresh,
                                      color: AppColors.textSecondary, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Search bar (below app bar)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      _AnimatedSearchBar(
                        controller: _searchController,
                        focusNode: _focusNode,
                        isSearching: _isSearching,
                        onSubmitted: _handleSearch,
                        onChanged: (value) {
                          setState(() {
                            _showSuggestions =
                                _focusNode.hasFocus && value.isEmpty;
                          });
                        },
                      ),
                      if (_showSuggestions) ...[
                        const SizedBox(height: 12),
                        SearchSuggestions(
                          recentSearches: _recentSearches,
                          trendingSearches: _trendingSearches,
                          onSelected: (query) {
                            _searchController.text = query;
                            _handleSearch(query);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Content: discovery view or results
              businessesAsync.when(
                data: (businesses) {
                  if (businesses.isEmpty && !_hasSearched) {
                    return _DiscoveryView(
                      onCategoryTap: (query) {
                        _searchController.text = query;
                        _handleSearch(query);
                      },
                      onTrendingTap: (query) {
                        _searchController.text = query;
                        _handleSearch(query);
                      },
                    );
                  }

                  if (businesses.isEmpty && _hasSearched) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _NoResultsState(
                        query: _searchController.text,
                        onRetry: () =>
                            _handleSearch(_searchController.text),
                        onClear: () {
                          setState(() {
                            _hasSearched = false;
                            _searchController.clear();
                          });
                          ref.read(scoutResultsProvider.notifier).clear();
                        },
                      ),
                    );
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Row(
                            children: [
                              PulseDot(
                                  color: AppColors.success,
                                  size: 6,
                                  pulse: true),
                              const SizedBox(width: 8),
                              Text(
                                '${businesses.length} results',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _hasSearched = false;
                                    _searchController.clear();
                                  });
                                  ref
                                      .read(scoutResultsProvider.notifier)
                                      .clear();
                                },
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        sliver: SliverList.builder(
                          itemCount: businesses.length,
                          itemBuilder: (context, index) {
                            final business = businesses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: BusinessCard(
                                business: business,
                                onTap: () => context
                                    .push('/business/${business.id}'),
                              ),
                            )
                                .animate(
                                    delay: Duration(
                                        milliseconds: 50 * index))
                                .fadeIn(duration: 300.ms)
                                .slideX(
                                    begin: -0.03,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic);
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SearchSkeleton(),
                ),
                error: (error, _) {
                  final isNoConnection = error is NoConnectionException;
                  final isServer = error is ServerException;
                  final icon = isNoConnection
                      ? Icons.wifi_off_rounded
                      : isServer
                          ? Icons.cloud_off_rounded
                          : Icons.error_outline_rounded;
                  final title = isNoConnection
                      ? 'No internet connection'
                      : isServer
                          ? 'Server error'
                          : 'Search failed';
                  final subtitle = isNoConnection
                      ? 'Check your connection and try again'
                      : isServer
                          ? 'Our servers are having issues. Try again in a moment.'
                          : error.toString();

                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon,
                                size: 56, color: AppColors.textTertiary),
                            const SizedBox(height: 16),
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text(subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textTertiary)),
                            const SizedBox(height: 24),
                            BrutalButton(
                              label: 'Retry',
                              onPressed: () => _handleSearch(
                                  _searchController.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Discovery View — shown before any search
// ---------------------------------------------------------------------------

class _DiscoveryView extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String> onTrendingTap;

  const _DiscoveryView({
    required this.onCategoryTap,
    required this.onTrendingTap,
  });

  static const _categories = [
    _Category('Dentists', Icons.medical_services_rounded, AppColors.info),
    _Category('Restaurants', Icons.restaurant_rounded, AppColors.primary),
    _Category('Plumbers', Icons.plumbing_rounded, AppColors.success),
    _Category('Lawyers', Icons.gavel_rounded, AppColors.secondary),
    _Category('Hair Salons', Icons.content_cut_rounded, Color(0xFFFF6B9D)),
    _Category('Gyms', Icons.fitness_center_rounded, Color(0xFF38BDF8)),
    _Category('Cafes', Icons.coffee_rounded, Color(0xFFFFD166)),
    _Category('Retail', Icons.storefront_rounded, Color(0xFF6EE7B7)),
  ];

  static const _trending = [
    'auto repair shops Chicago',
    'yoga studios Denver',
    'bakeries Brooklyn',
    'veterinary clinics Dallas',
  ];

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Hero message
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your\nnext client',
                style: TextStyle(
                  fontFamily: AppTypography.displayLarge.fontFamily,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search any business niche and city to discover leads with weak web presence.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.05, duration: 500.ms, curve: Curves.easeOutCubic),

        // Categories label
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Text(
            'POPULAR NICHES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
        ),

        // Featured category — full width
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _FeaturedCategoryCard(
            category: _categories[0],
            onTap: () => onCategoryTap(_categories[0].name),
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.97, 0.97),
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),

        const SizedBox(height: 10),

        // Remaining categories — 2 column grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(_categories.length - 1, (index) {
              final cat = _categories[index + 1];
              return _CategoryCard(
                category: cat,
                index: index + 1,
                onTap: () => onCategoryTap(cat.name),
              );
            }),
          ),
        ),

        // Trending section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.2),
                      AppColors.success.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    size: 12, color: AppColors.success),
              ),
              const SizedBox(width: 8),
              Text(
                'TRENDING SEARCHES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Trending list
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_trending.length, (index) {
                final isLast = index == _trending.length - 1;
                return _TrendingTile(
                  query: _trending[index],
                  index: index,
                  showDivider: !isLast,
                  onTap: () => onTrendingTap(_trending[index]),
                );
              }),
            ),
          ),
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.04, duration: 450.ms, curve: Curves.easeOutCubic),

        // How it works
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
          child: Text(
            'HOW IT WORKS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overlapping step circles
              SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 2,
                      child: _StepCircle(
                        step: '1',
                        icon: Icons.search_rounded,
                        color: AppColors.primary,
                        size: 56,
                      ),
                    ),
                    Positioned(
                      left: 40,
                      top: 4,
                      child: _StepCircle(
                        step: '2',
                        icon: Icons.analytics_rounded,
                        color: AppColors.info,
                        size: 52,
                      ),
                    ),
                    Positioned(
                      left: 80,
                      top: 6,
                      child: _StepCircle(
                        step: '3',
                        icon: Icons.send_rounded,
                        color: AppColors.success,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Labels with matching offsets
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text('Search',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 24 - 16),
                  SizedBox(
                    width: 52,
                    child: Text('Audit',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 28 - 12),
                  SizedBox(
                    width: 48,
                    child: Text('Outreach',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: 500.ms)
            .fadeIn(duration: 400.ms),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Category card
// ---------------------------------------------------------------------------

class _Category {
  final String name;
  final IconData icon;
  final Color color;
  const _Category(this.name, this.icon, this.color);
}

class _CategoryCard extends StatefulWidget {
  final _Category category;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusL),
            border: Border.all(
              color: cat.color.withValues(alpha: 0.12),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cat.color.withValues(alpha: 0.05),
                blurRadius: 12,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cat.color.withValues(alpha: 0.15),
                      cat.color.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cat.icon, size: 18, color: cat.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 200 + widget.index * 50))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

// ---------------------------------------------------------------------------
// Trending tile
// ---------------------------------------------------------------------------

class _TrendingTile extends StatefulWidget {
  final String query;
  final int index;
  final bool showDivider;
  final VoidCallback onTap;

  const _TrendingTile({
    required this.query,
    required this.index,
    required this.showDivider,
    required this.onTap,
  });

  @override
  State<_TrendingTile> createState() => _TrendingTileState();
}

class _TrendingTileState extends State<_TrendingTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            color: _pressed
                ? AppColors.textPrimary.withValues(alpha: 0.04)
                : Colors.transparent,
            padding: EdgeInsets.fromLTRB(
                widget.index.isOdd ? 24 : 14, 12, 14, 12),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    size: 16, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.query,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.north_west_rounded,
                    size: 12, color: AppColors.textTertiary),
              ],
            ),
          ),
          if (widget.showDivider)
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 42),
              color: AppColors.divider,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step badge for "how it works"
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Featured category card — full-width dominant card
// ---------------------------------------------------------------------------

class _FeaturedCategoryCard extends StatefulWidget {
  final _Category category;
  final VoidCallback onTap;

  const _FeaturedCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  State<_FeaturedCategoryCard> createState() => _FeaturedCategoryCardState();
}

class _FeaturedCategoryCardState extends State<_FeaturedCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.light();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GlowCard(
          glowColor: cat.color,
          glowIntensity: 0.4,
          padding: const EdgeInsets.all(16),
          child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cat.color.withValues(alpha: 0.2),
                        cat.color.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, size: 22, color: cat.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Most popular niche',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cat.color.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: cat.color),
              ],
            ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step circle — overlapping numbered circles
// ---------------------------------------------------------------------------

class _StepCircle extends StatelessWidget {
  final String step;
  final IconData icon;
  final Color color;
  final double size;

  const _StepCircle({
    required this.step,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: size * 0.38, color: color)),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No results state (only shown after actual search)
// ---------------------------------------------------------------------------

class _NoResultsState extends StatelessWidget {
  final String query;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  const _NoResultsState({
    required this.query,
    required this.onRetry,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.primary.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(Icons.search_off_rounded,
                      size: 24,
                      color: AppColors.primary.withValues(alpha: 0.6)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No businesses found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different niche or city combination.\nFor example: "dentists Austin"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BrutalButton.secondary(
                  label: 'Back',
                  icon: Icons.arrow_back_rounded,
                  onPressed: onClear,
                ),
                const SizedBox(width: 12),
                BrutalButton(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.95, 0.95),
              duration: 450.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Search Bar — rotating placeholder + glow on focus
// ---------------------------------------------------------------------------

class _AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  const _AnimatedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onSubmitted,
    required this.onChanged,
  });

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _hasFocus = false;

  int _placeholderIndex = 0;
  Timer? _placeholderTimer;

  static const _placeholders = [
    '"dentists Austin"',
    '"restaurants Miami"',
    '"plumbers Chicago"',
    '"hair salons NYC"',
    '"gyms San Diego"',
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    widget.focusNode.addListener(_onFocusChange);

    _placeholderTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (mounted && !_hasFocus && widget.controller.text.isEmpty) {
          setState(() {
            _placeholderIndex =
                (_placeholderIndex + 1) % _placeholders.length;
          });
        }
      },
    );
  }

  void _onFocusChange() {
    setState(() => _hasFocus = widget.focusNode.hasFocus);
    if (widget.focusNode.hasFocus) {
      _glowController.repeat();
    } else {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _placeholderTimer?.cancel();
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppColors.radiusL + 1),
            gradient: _hasFocus
                ? SweepGradient(
                    center: Alignment.center,
                    startAngle: _glowController.value * 6.28,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.primary.withValues(alpha: 0.0),
                      AppColors.secondary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.0),
                      AppColors.primary.withValues(alpha: 0.4),
                    ],
                  )
                : null,
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: EdgeInsets.all(_hasFocus ? 1.5 : 0),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search businesses  ${_placeholders[_placeholderIndex]}',
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _hasFocus
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
              suffixIcon: widget.isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: ForgeLoader(size: 20, strokeWidth: 2),
                    )
                  : widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                size: 16, color: AppColors.background),
                          ),
                          onPressed: () =>
                              widget.onSubmitted(widget.controller.text),
                        )
                      : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusL),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusL),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusL),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: widget.onSubmitted,
            onChanged: (value) {
              setState(() {});
              widget.onChanged(value);
            },
          ),
        );
      },
    );
  }
}

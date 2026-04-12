import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/profile.dart';
import '../../providers/auto_audit_provider.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/lead_item.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/search_suggestions.dart';
import '../../widgets/app_button.dart';
import '../../utils/haptics.dart';
import '../../utils/network.dart';
import '../../widgets/paywall_dialog.dart';

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
    final profile = profileAsync.valueOrNull;

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
      if (mounted) {
        if (e is LimitReachedException) {
          ref.read(scoutResultsProvider.notifier).clear();
          Haptics.heavy();
          _showPaywall();
        } else if (e is ProRequiredException) {
          Haptics.heavy();
          _showPaywall();
        }
        // Other exceptions propagate to the AsyncValue error state
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _showPaywall() {
    showPaywallDialog(
      context,
      title: 'Search Limit Reached',
      message: 'You\'ve used all 5 free searches this month.\n\nUpgrade to Pro for unlimited searches, audits, demos, and AI outreach messages.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(scoutResultsProvider);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Custom title area
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.pageHorizontal,
                MediaQuery.of(context).padding.top + 20,
                AppConstants.pageHorizontal,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scout',
                    style: AppTypography.displayLarge(context),
                  ),
                  const SizedBox(height: AppConstants.contentGap),
                  Text(
                    'Find businesses to help',
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: CupertinoDynamicColor.resolve(
                        AppColors.textSecondary,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pageHorizontal,
                AppConstants.sectionGap,
                AppConstants.pageHorizontal,
                0,
              ),
              child: Column(
                children: [
                  _StyledSearchBar(
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
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.pageHorizontal,
                        AppConstants.itemGap,
                        AppConstants.pageHorizontal,
                        0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${businesses.length} RESULTS',
                            style: AppTypography.labelSmall(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                AppColors.textTertiary,
                                context,
                              ),
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
                              style: AppTypography.labelLarge(context).copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  AppColors.accent,
                                  context,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      AppConstants.itemGap,
                      AppConstants.pageHorizontal,
                      100,
                    ),
                    sliver: SliverList.builder(
                      itemCount: businesses.length,
                      itemBuilder: (context, index) {
                        final business = businesses[index];
                        return LeadItem(
                          business: business,
                          showChevron: true,
                          showDivider: index < businesses.length - 1,
                          onTap: () {
                            // Fire auto-audit in background if enabled and business not yet audited
                            final autoAudit = ref.read(autoAuditProvider);
                            if (autoAudit && !business.isAudited) {
                              final profile = ref.read(profileNotifierProvider).valueOrNull;
                              final canAudit = profile == null ||
                                  profile.isPro ||
                                  profile.auditsThisMonth < 3;
                              if (canAudit) {
                                triggerAutoAudit(ref, business.id);
                              }
                            }
                            context.push('/business/${business.id}');
                          },
                        )
                            .animate(
                                delay: Duration(
                                    milliseconds:
                                        AppConstants.staggerDelay.inMilliseconds *
                                            index))
                            .fadeIn(duration: 300.ms)
                            .slideY(
                                begin: AppConstants.entranceSlideDistance / 100,
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
                  ? CupertinoIcons.wifi_slash
                  : isServer
                      ? CupertinoIcons.cloud
                      : CupertinoIcons.exclamationmark_circle;
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
                            size: 56,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.textTertiary, context)),
                        const SizedBox(height: 16),
                        Text(title,
                            style: AppTypography.titleMedium(context).copyWith(
                              fontSize: 18,
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textSecondary, context),
                            )),
                        const SizedBox(height: 8),
                        Text(subtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelLarge(context).copyWith(
                              color: CupertinoDynamicColor.resolve(
                                  AppColors.textTertiary, context),
                            )),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Retry',
                          compact: true,
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
    _Category('Dentists', CupertinoIcons.heart, AppColors.accent),
    _Category('Restaurants', CupertinoIcons.cart, AppColors.accent),
    _Category('Plumbers', CupertinoIcons.wrench, AppColors.scoreGood),
    _Category('Lawyers', CupertinoIcons.book, AppColors.scoreMid),
    _Category('Hair Salons', CupertinoIcons.scissors, Color(0xFFFF6B9D)),
    _Category('Gyms', CupertinoIcons.sportscourt, Color(0xFF38BDF8)),
    _Category('Cafes', CupertinoIcons.drop, Color(0xFFFFD166)),
    _Category('Retail', CupertinoIcons.bag, Color(0xFF6EE7B7)),
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
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            AppConstants.sectionGap,
            AppConstants.pageHorizontal,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your\nnext client',
                style: AppTypography.displayLarge(context).copyWith(
                  fontSize: 36,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search any business niche and city to discover leads with weak web presence.',
                style: AppTypography.bodyLarge(context).copyWith(
                  height: 1.5,
                  color: CupertinoDynamicColor.resolve(
                    AppColors.textSecondary,
                    context,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(
              begin: AppConstants.entranceSlideDistance / 100,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),

        // Categories label
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            AppConstants.sectionGap,
            AppConstants.pageHorizontal,
            12,
          ),
          child: Text(
            'POPULAR NICHES',
            style: AppTypography.labelSmall(context),
          ),
        ),

        // Featured category — full width
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pageHorizontal,
          ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pageHorizontal,
          ),
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
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            AppConstants.sectionGap,
            AppConstants.pageHorizontal,
            12,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoDynamicColor.resolve(AppColors.scoreGood, context)
                          .withValues(alpha: 0.2),
                      CupertinoDynamicColor.resolve(AppColors.scoreGood, context)
                          .withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(CupertinoIcons.graph_square,
                    size: 12,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context)),
              ),
              const SizedBox(width: 8),
              Text(
                'TRENDING SEARCHES',
                style: AppTypography.labelSmall(context),
              ),
            ],
          ),
        ),

        // Trending list
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pageHorizontal,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(AppColors.surface, context),
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              border: Border.all(
                color: CupertinoDynamicColor.resolve(AppColors.border, context),
                width: 0.5,
              ),
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
            .slideY(
              begin: AppConstants.entranceSlideDistance / 100,
              duration: 450.ms,
              curve: Curves.easeOutCubic,
            ),

        // How it works
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            AppConstants.sectionGap + 4,
            AppConstants.pageHorizontal,
            0,
          ),
          child: Text(
            'HOW IT WORKS',
            style: AppTypography.labelSmall(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pageHorizontal,
            12,
            AppConstants.pageHorizontal,
            120,
          ),
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
                        icon: CupertinoIcons.search,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.accent, context),
                        size: 56,
                      ),
                    ),
                    Positioned(
                      left: 40,
                      top: 4,
                      child: _StepCircle(
                        step: '2',
                        icon: CupertinoIcons.chart_bar,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.scoreMid, context),
                        size: 52,
                      ),
                    ),
                    Positioned(
                      left: 80,
                      top: 6,
                      child: _StepCircle(
                        step: '3',
                        icon: CupertinoIcons.paperplane,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.scoreGood, context),
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
                            color: CupertinoDynamicColor.resolve(
                                AppColors.accent, context)),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 24 - 16),
                  SizedBox(
                    width: 52,
                    child: Text('Audit',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.scoreMid, context)),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 28 - 12),
                  SizedBox(
                    width: 48,
                    child: Text('Outreach',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CupertinoDynamicColor.resolve(
                                AppColors.scoreGood, context)),
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
    final catColor = CupertinoDynamicColor.resolve(cat.color, context);

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
        duration: AppConstants.quickAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.surface, context),
            borderRadius: BorderRadius.circular(AppColors.radiusL),
            border: Border.all(
              color: catColor.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      catColor.withValues(alpha: 0.15),
                      catColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cat.icon, size: 18, color: catColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cat.name,
                  style: AppTypography.titleMedium(context).copyWith(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(CupertinoIcons.chevron_forward,
                  size: 12,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context)),
            ],
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(
            milliseconds: 200 +
                widget.index * AppConstants.staggerDelay.inMilliseconds,
          ),
        )
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: AppConstants.entranceSlideDistance / 100,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
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
            duration: AppConstants.quickAnimation,
            color: _pressed
                ? CupertinoDynamicColor.resolve(AppColors.textPrimary, context)
                    .withValues(alpha: 0.04)
                : const Color(0x00000000),
            padding: EdgeInsets.fromLTRB(
                widget.index.isOdd ? 24 : 14, 12, 14, 12),
            child: Row(
              children: [
                Icon(CupertinoIcons.graph_square,
                    size: 16,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.query,
                    style: AppTypography.bodyMedium(context),
                  ),
                ),
                Icon(CupertinoIcons.arrow_up_left,
                    size: 12,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context)),
              ],
            ),
          ),
          if (widget.showDivider)
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 42),
              color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Featured category card — full-width dominant card (no BrutalCard)
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
    final catColor = CupertinoDynamicColor.resolve(cat.color, context);

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
        duration: AppConstants.quickAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.surface, context),
            borderRadius: BorderRadius.circular(AppColors.radiusL),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(AppColors.border, context),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      catColor.withValues(alpha: 0.2),
                      catColor.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, size: 22, color: catColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.name,
                      style: AppTypography.titleMedium(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Most popular niche',
                      style: AppTypography.chip(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: catColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_forward,
                  size: 14, color: catColor),
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
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.background, context),
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
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);

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
                    accentColor.withValues(alpha: 0.1),
                    accentColor.withValues(alpha: 0.0),
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
                        accentColor.withValues(alpha: 0.12),
                        accentColor.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(CupertinoIcons.search,
                      size: 24,
                      color: accentColor.withValues(alpha: 0.6)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No businesses found',
              style: AppTypography.titleMedium(context).copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different niche or city combination.\nFor example: "dentists Austin"',
              style: AppTypography.bodyMedium(context).copyWith(
                height: 1.5,
                color: CupertinoDynamicColor.resolve(
                    AppColors.textTertiary, context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  label: 'Back',
                  variant: AppButtonVariant.secondary,
                  compact: true,
                  onPressed: onClear,
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: 'Retry',
                  compact: true,
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
// Styled Search Bar — CupertinoTextField with custom styling
// ---------------------------------------------------------------------------

class _StyledSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  const _StyledSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onSubmitted,
    required this.onChanged,
  });

  @override
  State<_StyledSearchBar> createState() => _StyledSearchBarState();
}

class _StyledSearchBarState extends State<_StyledSearchBar> {
  bool _hasFocus = false;

  int _placeholderIndex = 0;
  Timer? _placeholderTimer;

  static const _placeholders = [
    'dentists Austin',
    'restaurants Miami',
    'plumbers Chicago',
    'hair salons NYC',
    'gyms San Diego',
  ];

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _placeholderTimer?.cancel();
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      placeholder: 'Search  ${_placeholders[_placeholderIndex]}',
      placeholderStyle: TextStyle(
        color: CupertinoDynamicColor.resolve(AppColors.textTertiary, context),
        fontSize: 15,
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: widget.isSearching
            ? const CupertinoActivityIndicator(radius: 8)
            : Icon(
                CupertinoIcons.search,
                size: 18,
                color: CupertinoDynamicColor.resolve(
                  _hasFocus ? AppColors.accent : AppColors.textTertiary,
                  context,
                ),
              ),
      ),
      suffix: widget.controller.text.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 18,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context),
                ),
              ),
            )
          : null,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.searchField, context),
        borderRadius: BorderRadius.circular(AppColors.radiusM),
      ),
      onSubmitted: widget.onSubmitted,
      onChanged: (value) {
        setState(() {});
        widget.onChanged(value);
      },
      textInputAction: TextInputAction.search,
    );
  }
}

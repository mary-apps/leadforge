import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/theme.dart';
import '../providers/subscription_provider.dart';
import '../utils/haptics.dart';
import '../widgets/ios_toast.dart';

void showPaywallDialog(BuildContext context, {String? title, String? message}) {
  showCupertinoModalPopup(
    context: context,
    builder: (ctx) => _PaywallSheet(title: title, message: message),
  );
}

class _PaywallSheet extends ConsumerStatefulWidget {
  final String? title;
  final String? message;

  const _PaywallSheet({this.title, this.message});

  @override
  ConsumerState<_PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<_PaywallSheet> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final bgColor = CupertinoDynamicColor.resolve(AppColors.surface, context);
    final accentColor = CupertinoDynamicColor.resolve(AppColors.accent, context);

    // Get the price string from RevenueCat
    String? priceString;
    dynamic package;
    offeringsAsync.whenData((offerings) {
      if (offerings != null && offerings.current != null) {
        package = offerings.current!.monthly ?? offerings.current!.availablePackages.firstOrNull;
        if (package != null) {
          priceString = package.storeProduct.priceString;
        }
      }
    });

    final features = [
      'Unlimited audits & reports',
      'Unlimited territories',
      'Team collaboration (up to 5 members)',
      'Priority support',
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(AppColors.divider, context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title ?? 'Upgrade to Pro',
            style: AppTypography.headlineLarge(context),
            textAlign: TextAlign.center,
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.message!,
              style: AppTypography.bodyMedium(context).copyWith(
                color: CupertinoDynamicColor.resolve(AppColors.textSecondary, context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),

          // Features list
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_circle_fill,
                        size: 18,
                        color: CupertinoDynamicColor.resolve(
                            AppColors.scoreGood, context)),
                    const SizedBox(width: 10),
                    Text(feature, style: AppTypography.bodyLarge(context)),
                  ],
                ),
              )),
          const SizedBox(height: 20),

          // Price + Purchase button
          GestureDetector(
            onTap: _isPurchasing
                ? null
                : () async {
                    if (package == null) return;
                    setState(() => _isPurchasing = true);
                    Haptics.medium();
                    final result = await ref
                        .read(subscriptionProvider.notifier)
                        .purchase(package);
                    if (!context.mounted) return;
                    setState(() => _isPurchasing = false);
                    if (result.success) {
                      Navigator.pop(context);
                      IosToast.show(context, 'Welcome to Pro!');
                    } else if (result.error != null) {
                      IosToast.show(context, result.error!);
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppColors.radiusL),
              ),
              child: Center(
                child: _isPurchasing
                    ? CupertinoActivityIndicator(
                        color: CupertinoDynamicColor.resolve(
                            AppColors.chipActiveFg, context))
                    : Text(
                        priceString != null
                            ? '$priceString / month'
                            : 'Upgrade to Pro',
                        style: AppTypography.button(context).copyWith(
                          color: CupertinoDynamicColor.resolve(
                              AppColors.chipActiveFg, context),
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Restore + Cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  Haptics.light();
                  final result = await ref
                      .read(subscriptionProvider.notifier)
                      .restore();
                  if (!context.mounted) return;
                  if (result.isPro) {
                    Navigator.pop(context);
                    IosToast.show(context, 'Pro restored!');
                  } else {
                    IosToast.show(context, 'No previous purchase found');
                  }
                },
                child: Text(
                  'Restore Purchases',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.accent, context),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: AppTypography.labelLarge(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.textTertiary, context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

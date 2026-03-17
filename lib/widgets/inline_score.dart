import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class InlineScore extends StatelessWidget {
  final int score;
  final String? statusText;
  final String? description;

  const InlineScore({
    super.key,
    required this.score,
    this.statusText,
    this.description,
  });

  String get _defaultStatusText {
    if (score >= 70) return 'Good web presence';
    if (score >= 40) return 'Needs improvement';
    return 'Poor web presence';
  }

  @override
  Widget build(BuildContext context) {
    final scoreCol = CupertinoDynamicColor.resolve(
      AppColors.scoreColor(score),
      context,
    );
    final dividerCol = CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: dividerCol, width: 1),
          bottom: BorderSide(color: dividerCol, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$score',
            style: AppTypography.scoreLarge(context),
          )
              .animate()
              .fadeIn(duration: AppConstants.countUpAnimation),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText ?? _defaultStatusText,
                  style: AppTypography.labelLarge(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: scoreCol,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: AppTypography.labelLarge(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

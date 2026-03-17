import 'package:flutter/cupertino.dart';

import '../config/constants.dart' as consts;
import '../config/theme.dart';

class NicheChips extends StatelessWidget {
  final Function(String) onSelected;
  final String? selectedNiche;

  const NicheChips({super.key, required this.onSelected, this.selectedNiche});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: consts.AppConstants.suggestedNiches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final niche = consts.AppConstants.suggestedNiches[index];
          final isSelected = selectedNiche == niche;
          return GestureDetector(
            onTap: () => onSelected(niche),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  isSelected ? AppColors.chipActive : AppColors.chipInactive,
                  context,
                ),
                borderRadius: BorderRadius.circular(AppColors.radiusXL),
              ),
              child: Text(
                niche,
                style: AppTypography.chip(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: CupertinoDynamicColor.resolve(
                    isSelected
                        ? AppColors.chipActiveFg
                        : AppColors.textSecondary,
                    context,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

class NicheChips extends StatelessWidget {
  final Function(String) onSelected;
  final String? selectedNiche;

  const NicheChips({
    super.key,
    required this.onSelected,
    this.selectedNiche,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.suggestedNiches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final niche = AppConstants.suggestedNiches[index];
          final isSelected = selectedNiche == niche;

          return GestureDetector(
            onTap: () => onSelected(niche),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.radiusS),
              ),
              child: Text(
                niche,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

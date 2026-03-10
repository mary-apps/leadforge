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
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.suggestedNiches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final niche = AppConstants.suggestedNiches[index];
          final isSelected = selectedNiche == niche;

          return ActionChip(
            label: Text(niche),
            onPressed: () => onSelected(niche),
            backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            labelStyle: AppTypography.bodyMedium.copyWith(
              color: isSelected ? AppColors.background : AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }
}

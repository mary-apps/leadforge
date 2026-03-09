import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

class NicheChips extends StatelessWidget {
  final Function(String) onSelected;
  
  const NicheChips({
    super.key,
    required this.onSelected,
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
          
          return ActionChip(
            label: Text(niche),
            onPressed: () => onSelected(niche),
            backgroundColor: AppColors.surface,
            side: BorderSide(color: AppColors.border),
            labelStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }
}

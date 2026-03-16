import 'package:flutter/cupertino.dart';
import '../config/constants.dart';

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
        itemCount: AppConstants.suggestedNiches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final niche = AppConstants.suggestedNiches[index];
          final isSelected = selectedNiche == niche;
          return GestureDetector(
            onTap: () => onSelected(niche),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue.resolveFrom(context)
                    : CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Text(
                niche,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const StatCell({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.numberLarge(context).copyWith(
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall(context),
        ),
      ],
    );
  }
}

class StatRow extends StatelessWidget {
  final List<StatCell> cells;

  const StatRow({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    final dividerColor = CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: cells[i],
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: i * 50),
                      duration: AppConstants.standardAnimation,
                    )
                    .slideY(
                      begin: AppConstants.entranceSlideDistance / 100,
                      end: 0,
                      delay: Duration(milliseconds: i * 50),
                      duration: AppConstants.standardAnimation,
                    ),
              ),
              if (i < cells.length - 1)
                Container(
                  width: 1,
                  color: dividerColor,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

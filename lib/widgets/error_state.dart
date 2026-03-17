import 'package:flutter/cupertino.dart';

import '../config/theme.dart';
import '../utils/network.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String title;
    final String subtitle;

    if (error is NoConnectionException) {
      icon = CupertinoIcons.wifi_slash;
      title = 'No connection';
      subtitle = 'Check your internet and try again';
    } else if (error is ServerException) {
      icon = CupertinoIcons.exclamationmark_triangle;
      title = 'Server error';
      subtitle = 'Something went wrong on our end';
    } else {
      icon = CupertinoIcons.exclamationmark_circle;
      title = 'Something went wrong';
      subtitle = 'Please try again';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: CupertinoDynamicColor.resolve(
                  AppColors.textTertiary, context),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium(context).copyWith(
                color: CupertinoDynamicColor.resolve(
                    AppColors.textSecondary, context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Try Again',
              onPressed: onRetry,
              variant: AppButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }
}

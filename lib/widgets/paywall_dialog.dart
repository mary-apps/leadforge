import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// Show a standard paywall dialog for free tier limits.
void showPaywallDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe Later'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            context.push('/settings');
          },
          child: const Text('Upgrade to Pro'),
        ),
      ],
    ),
  );
}

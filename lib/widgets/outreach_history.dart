import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../config/theme.dart';
import '../models/message.dart';

class OutreachHistory extends StatelessWidget {
  final List<Message> messages;

  const OutreachHistory({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OUTREACH HISTORY',
          style: AppTypography.labelSmall(context).copyWith(
            color: CupertinoDynamicColor.resolve(
                AppColors.textSecondary, context),
          ),
        ),
        const SizedBox(height: 10),
        ...messages.map((message) => _MessageItem(message: message)),
      ],
    );
  }
}

class _MessageItem extends StatelessWidget {
  final Message message;

  const _MessageItem({required this.message});

  IconData get _channelIcon {
    switch (message.channel) {
      case OutreachChannel.email:
        return CupertinoIcons.mail;
      case OutreachChannel.whatsapp:
        return CupertinoIcons.bubble_left;
      case OutreachChannel.instagram:
        return CupertinoIcons.camera;
      case OutreachChannel.phone:
        return CupertinoIcons.phone;
      case OutreachChannel.other:
        return CupertinoIcons.chat_bubble;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(message.createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoDynamicColor.resolve(AppColors.divider, context),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: channel + tone + time
          Row(
            children: [
              Icon(_channelIcon,
                  size: 14,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.accent, context)),
              const SizedBox(width: 6),
              Text(
                message.channelLabel,
                style: AppTypography.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· ${message.tone}',
                style: AppTypography.labelLarge(context),
              ),
              const Spacer(),
              Text(
                _timeAgo,
                style: AppTypography.chip(context).copyWith(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Message preview
          Text(
            message.content,
            style: AppTypography.bodyMedium(context).copyWith(
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Copy button
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              HapticFeedback.mediumImpact();
            },
            child: Text(
              'Copy',
              style: AppTypography.labelLarge(context).copyWith(
                color: CupertinoDynamicColor.resolve(
                    AppColors.accent, context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

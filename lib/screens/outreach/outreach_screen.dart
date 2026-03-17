import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/message.dart';
import '../../services/outreach_service.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ios_toast.dart';
import '../../utils/haptics.dart';

class OutreachScreen extends ConsumerStatefulWidget {
  final String businessId;

  const OutreachScreen({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<OutreachScreen> createState() => _OutreachScreenState();
}

class _OutreachScreenState extends ConsumerState<OutreachScreen> {
  OutreachChannel _selectedChannel = OutreachChannel.email;
  String _selectedTone = 'professional';
  String _selectedLanguage = 'en';
  bool _isGenerating = false;
  Message? _generatedMessage;

  final List<String> _tones = ['professional', 'friendly', 'direct'];
  static const _languages = {
    'en': 'English',
    'es': 'Espanol',
  };

  @override
  void initState() {
    super.initState();
    // Default to user's preferred language
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    final lang = profile?.preferredLanguage;
    if (lang != null) {
      _selectedLanguage = lang;
    }
  }

  Future<void> _generateMessage(Business business) async {
    final isPro = await ref.read(isProProvider.future);
    if (!isPro) {
      Haptics.heavy();
      _showPaywall();
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedMessage = null;
    });
    Haptics.medium();

    try {
      final message = await OutreachService.generateMessage(
        businessId: business.id,
        channel: _selectedChannel,
        tone: _selectedTone,
        language: _selectedLanguage,
      );

      if (mounted) {
        setState(() {
          _generatedMessage = message;
          _isGenerating = false;
        });
        Haptics.medium();
        IosToast.show(context, 'Message generated');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        Haptics.heavy();
        IosToast.show(context, 'Error: $e');
      }
    }
  }

  void _showPaywall() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Pro Feature'),
        content: const Text(
          'AI message generation is a Pro feature.\n\nUpgrade to Pro for unlimited AI messages, 4 outreach channels, 3 tone options, and bilingual (EN/ES) support.',
        ),
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

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    Haptics.medium();
    IosToast.show(context, 'Message copied to clipboard');
  }

  Future<void> _markAsSent(Message message) async {
    try {
      await OutreachService.markSent(message.id);
      if (!mounted) return;
      Haptics.medium();
      IosToast.show(context, 'Marked as sent');
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, 'Error: $e');
    }
  }

  void _regenerate(Business business) {
    Haptics.light();
    _generateMessage(business);
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));
    final bgColor =
        CupertinoDynamicColor.resolve(AppColors.background, context);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: SafeArea(
        child: businessAsync.when(
          data: (business) {
            if (business == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        '\u2190 Back',
                        style: AppTypography.labelLarge(context),
                      ),
                    ),
                    const Expanded(
                      child: Center(child: Text('Business not found')),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back nav
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      '\u2190 ${business.name}',
                      style: AppTypography.labelLarge(context),
                    ),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Title
                  Text(
                    'Compose Outreach',
                    style: AppTypography.headlineLarge(context),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Channel selector
                  Text(
                    'CHANNEL',
                    style: AppTypography.labelSmall(context),
                  ),
                  const SizedBox(height: AppConstants.itemGap),
                  Wrap(
                    spacing: AppConstants.chipGap,
                    runSpacing: AppConstants.chipGap,
                    children: OutreachChannel.values.map((channel) {
                      final isSelected = channel == _selectedChannel;
                      return _ChannelChip(
                        channel: channel,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedChannel = channel);
                          Haptics.light();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Tone selector
                  Text(
                    'TONE',
                    style: AppTypography.labelSmall(context),
                  ),
                  const SizedBox(height: AppConstants.itemGap),
                  Wrap(
                    spacing: AppConstants.chipGap,
                    runSpacing: AppConstants.chipGap,
                    children: _tones.map((tone) {
                      final isSelected = tone == _selectedTone;
                      return _ToneChip(
                        tone: tone,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedTone = tone);
                          Haptics.light();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  // Language selector
                  Text(
                    'LANGUAGE',
                    style: AppTypography.labelSmall(context),
                  ),
                  const SizedBox(height: AppConstants.itemGap),
                  Wrap(
                    spacing: AppConstants.chipGap,
                    children: _languages.entries.map((entry) {
                      final isSelected = entry.key == _selectedLanguage;
                      return _ToneChip(
                        tone: entry.value,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedLanguage = entry.key);
                          Haptics.light();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.sectionGap),

                  if (_generatedMessage == null && !_isGenerating)
                    AppButton(
                      label: 'Generate Message',
                      onPressed: () => _generateMessage(business),
                    ),

                  if (_isGenerating) _GeneratingAnimation(),

                  if (_generatedMessage != null)
                    _MessageResult(
                      message: _generatedMessage!,
                      onCopy: _copyMessage,
                      onRegenerate: () => _regenerate(business),
                      onMarkSent: () => _markAsSent(_generatedMessage!),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

// Channel chip using editorial design system
class _ChannelChip extends StatelessWidget {
  final OutreachChannel channel;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = _getChannelLabel(channel);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.quickAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            isSelected ? AppColors.chipActive : AppColors.chipInactive,
            context,
          ),
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        child: Text(
          label,
          style: AppTypography.chip(context).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: CupertinoDynamicColor.resolve(
              isSelected ? AppColors.chipActiveFg : AppColors.textSecondary,
              context,
            ),
          ),
        ),
      ),
    );
  }

  String _getChannelLabel(OutreachChannel channel) {
    switch (channel) {
      case OutreachChannel.email:
        return 'Email';
      case OutreachChannel.whatsapp:
        return 'WhatsApp';
      case OutreachChannel.instagram:
        return 'Instagram';
      case OutreachChannel.phone:
        return 'Phone';
      case OutreachChannel.other:
        return 'Other';
    }
  }
}

// Tone chip using editorial design system
class _ToneChip extends StatelessWidget {
  final String tone;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToneChip({
    required this.tone,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.quickAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            isSelected ? AppColors.chipActive : AppColors.chipInactive,
            context,
          ),
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        child: Text(
          tone[0].toUpperCase() + tone.substring(1),
          style: AppTypography.chip(context).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: CupertinoDynamicColor.resolve(
              isSelected ? AppColors.chipActiveFg : AppColors.textSecondary,
              context,
            ),
          ),
        ),
      ),
    );
  }
}

// Generating animation
class _GeneratingAnimation extends StatefulWidget {
  @override
  State<_GeneratingAnimation> createState() => _GeneratingAnimationState();
}

class _GeneratingAnimationState extends State<_GeneratingAnimation> {
  int _currentStep = 0;

  final List<String> _steps = [
    'Analyzing business...',
    'Crafting message...',
    'Optimizing tone...',
  ];

  @override
  void initState() {
    super.initState();
    _animateSteps();
  }

  Future<void> _animateSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() => _currentStep = i);
        Haptics.light();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
      ),
      child: Column(
        children: [
          const CupertinoActivityIndicator(radius: 14),
          const SizedBox(height: 20),
          ...List.generate(_steps.length, (index) {
            final isActive = index == _currentStep;
            final isDone = index < _currentStep;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: AppConstants.quickAnimation,
                    child: Icon(
                      isDone
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      key: ValueKey('gen-$index-$isDone'),
                      size: 16,
                      color: CupertinoDynamicColor.resolve(
                        isActive || isDone
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[index],
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: CupertinoDynamicColor.resolve(
                          isActive
                              ? AppColors.textPrimary
                              : isDone
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                          context,
                        ),
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// Message result
class _MessageResult extends StatelessWidget {
  final Message message;
  final Function(String) onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onMarkSent;

  const _MessageResult({
    required this.message,
    required this.onCopy,
    required this.onRegenerate,
    required this.onMarkSent,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Generated label
        Text(
          'GENERATED MESSAGE',
          style: AppTypography.labelSmall(context),
        ),
        const SizedBox(height: AppConstants.itemGap),

        // Message content with divider borders
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: dividerColor),
              bottom: BorderSide(color: dividerColor),
            ),
          ),
          child: Text(
            message.content,
            style: AppTypography.bodyMedium(context).copyWith(
              height: 1.6,
              color: CupertinoDynamicColor.resolve(
                  AppColors.textSecondary, context),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.sectionGap),

        // Copy button — primary
        AppButton(
          label: 'Copy Message',
          onPressed: () => onCopy(message.content),
        ),
        const SizedBox(height: AppConstants.itemGap),

        // Mark as sent — ghost
        AppButton(
          label: 'Mark as Sent',
          variant: AppButtonVariant.ghost,
          onPressed: onMarkSent,
        ),
        const SizedBox(height: AppConstants.itemGap),

        // Regenerate — secondary
        AppButton(
          label: 'Regenerate',
          variant: AppButtonVariant.secondary,
          onPressed: onRegenerate,
        ),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }
}

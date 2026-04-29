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
import '../../utils/network.dart';
import '../../utils/outreach_launcher.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_state.dart';
import '../../widgets/ios_toast.dart';
import '../../widgets/paywall_dialog.dart';
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

  final List<String> _tones = ['professional', 'casual', 'direct'];
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
    } on AuthExpiredException {
      if (mounted) {
        setState(() => _isGenerating = false);
        IosToast.show(context, 'Session expired. Please sign in again.');
      }
    } on ProRequiredException {
      if (mounted) {
        setState(() => _isGenerating = false);
        Haptics.heavy();
        _showPaywall();
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
    showPaywallDialog(
      context,
      title: 'Pro Feature',
      message: 'AI message generation is a Pro feature.\n\nUpgrade to Pro for unlimited AI messages, 4 outreach channels, 3 tone options, and bilingual (EN/ES) support.',
    );
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    Haptics.medium();
    IosToast.show(context, 'Message copied to clipboard');
  }

  void _regenerate(Business business) {
    Haptics.light();
    _generateMessage(business);
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoDynamicColor.resolve(AppColors.background, context),
      child: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header with back button
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHorizontal,
                      12,
                      AppConstants.pageHorizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Haptics.light();
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/business/${widget.businessId}');
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.chevron_back,
                                  size: 18,
                                  color: CupertinoDynamicColor.resolve(
                                      AppColors.accent, context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  business.name,
                                  style: AppTypography.bodyMedium(context)
                                      .copyWith(
                                    color: CupertinoDynamicColor.resolve(
                                        AppColors.accent, context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create Outreach',
                          style: AppTypography.displayLarge(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generate a personalized message',
                          style: AppTypography.bodyMedium(context).copyWith(
                            color: CupertinoDynamicColor.resolve(
                                AppColors.textSecondary, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Options
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pageHorizontal,
                  AppConstants.sectionGap,
                  AppConstants.pageHorizontal,
                  AppConstants.sectionGap,
                ),
                sliver: SliverList.list(
                  children: [
                    // Channel
                    const _SectionLabel('CHANNEL'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                    const SizedBox(height: 22),

                    // Tone + Language in a single row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tone
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('TONE'),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Language
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('LANG'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: _languages.entries.map((entry) {
                                final isSelected =
                                    entry.key == _selectedLanguage;
                                return _ToneChip(
                                  tone: entry.value,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(
                                        () => _selectedLanguage = entry.key);
                                    Haptics.light();
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    if (_generatedMessage == null && !_isGenerating)
                      _GradientCTA(
                        label: 'Generate Message',
                        icon: CupertinoIcons.paperplane,
                        onPressed: () => _generateMessage(business),
                      ),

                    if (_isGenerating) const _GeneratingAnimation(),

                    if (_generatedMessage != null)
                      _MessageResult(
                        message: _generatedMessage!,
                        business: business,
                        language: _selectedLanguage,
                        onCopy: _copyMessage,
                        onRegenerate: () => _regenerate(business),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const SafeArea(
            child: Center(child: CupertinoActivityIndicator())),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(businessProvider(widget.businessId)),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelSmall(context).copyWith(
        color: CupertinoDynamicColor.resolve(
            AppColors.textSecondary, context),
      ),
    );
  }
}

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
    final info = _getChannelInfo(channel, context);
    final color = info['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : CupertinoDynamicColor.resolve(AppColors.surface, context),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.border, context),
                  width: 0.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              info['icon'] as IconData,
              color: isSelected
                  ? CupertinoDynamicColor.resolve(
                      AppColors.chipActiveFg, context)
                  : CupertinoDynamicColor.resolve(
                      AppColors.textTertiary, context),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              info['name'] as String,
              style: AppTypography.bodyMedium(context).copyWith(
                color: isSelected
                    ? CupertinoDynamicColor.resolve(
                        AppColors.chipActiveFg, context)
                    : CupertinoDynamicColor.resolve(
                        AppColors.textPrimary, context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getChannelInfo(
      OutreachChannel channel, BuildContext context) {
    final chipColor =
        CupertinoDynamicColor.resolve(AppColors.chipActive, context);
    switch (channel) {
      case OutreachChannel.email:
        return {
          'name': 'Email',
          'icon': CupertinoIcons.mail,
          'color': chipColor,
        };
      case OutreachChannel.whatsapp:
        return {
          'name': 'WhatsApp',
          'icon': CupertinoIcons.chat_bubble,
          'color': chipColor,
        };
      case OutreachChannel.instagram:
        return {
          'name': 'Instagram',
          'icon': CupertinoIcons.camera,
          'color': chipColor,
        };
      case OutreachChannel.phone:
        return {
          'name': 'Phone',
          'icon': CupertinoIcons.phone,
          'color': chipColor,
        };
      case OutreachChannel.other:
        return {
          'name': 'Other',
          'icon': CupertinoIcons.ellipsis,
          'color': chipColor,
        };
    }
  }
}

// Tone chip
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoDynamicColor.resolve(AppColors.chipActive, context)
              : CupertinoDynamicColor.resolve(AppColors.surface, context),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.border, context),
                  width: 0.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CupertinoDynamicColor.resolve(
                            AppColors.accent, context)
                        .withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Text(
          tone[0].toUpperCase() + tone.substring(1),
          style: AppTypography.bodyMedium(context).copyWith(
            color: isSelected
                ? CupertinoDynamicColor.resolve(
                    AppColors.chipActiveFg, context)
                : CupertinoDynamicColor.resolve(
                    AppColors.textPrimary, context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Gradient CTA button
class _GradientCTA extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _GradientCTA({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_GradientCTA> createState() => _GradientCTAState();
}

class _GradientCTAState extends State<_GradientCTA> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Haptics.medium();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(AppColors.accent, context),
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            boxShadow: [
              BoxShadow(
                color: CupertinoDynamicColor.resolve(
                        AppColors.accent, context)
                    .withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 20,
                  color: CupertinoDynamicColor.resolve(
                      AppColors.chipActiveFg, context)),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.button(context).copyWith(
                    color: CupertinoDynamicColor.resolve(
                        AppColors.chipActiveFg, context),
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Generating animation
class _GeneratingAnimation extends StatefulWidget {
  const _GeneratingAnimation();

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppColors.border, context),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 24),
          ...List.generate(_steps.length, (index) {
            final isActive = index == _currentStep;
            final isDone = index < _currentStep;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isDone
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      key: ValueKey('gen-$index-$isDone'),
                      size: 18,
                      color: isActive
                          ? CupertinoDynamicColor.resolve(
                              AppColors.textSecondary, context)
                          : isDone
                              ? CupertinoDynamicColor.resolve(
                                  AppColors.scoreGood, context)
                              : CupertinoDynamicColor.resolve(
                                  AppColors.textTertiary, context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[index],
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: isActive
                            ? CupertinoDynamicColor.resolve(
                                AppColors.textPrimary, context)
                            : isDone
                                ? CupertinoDynamicColor.resolve(
                                    AppColors.textSecondary, context)
                                : CupertinoDynamicColor.resolve(
                                    AppColors.textTertiary, context),
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
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.97, 0.97), duration: 300.ms);
  }
}

// Message result card
class _MessageResult extends StatelessWidget {
  final Message message;
  final Business business;
  final String language;
  final Function(String) onCopy;
  final VoidCallback onRegenerate;

  const _MessageResult({
    required this.message,
    required this.business,
    required this.language,
    required this.onCopy,
    required this.onRegenerate,
  });

  Future<void> _handleWhatsApp(BuildContext context) async {
    Haptics.medium();
    final ok = await OutreachLauncher.openWhatsApp(
      phone: business.phone,
      content: message.content,
    );
    if (!ok && context.mounted) {
      _copyAndPromptManual(
        context,
        title: 'WhatsApp not available',
        body: 'Message copied. Open WhatsApp manually to paste it.',
      );
    }
  }

  Future<void> _handleEmail(BuildContext context) async {
    Haptics.medium();
    final subject = OutreachLauncher.emailSubjectFor(business.name, language);
    final ok = await OutreachLauncher.openEmail(
      subject: subject,
      body: message.content,
    );
    if (!ok && context.mounted) {
      _copyAndPromptManual(
        context,
        title: 'Mail not available',
        body: 'Message copied. Open your mail app manually to paste it.',
      );
    }
  }

  Future<void> _handleInstagram(BuildContext context) async {
    Haptics.medium();
    onCopy(message.content);
    if (!context.mounted) return;
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Message copied'),
        content: const Text(
          'Instagram does not allow pre-filled DMs. Open Instagram and paste the message.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await OutreachLauncher.openInstagram();
            },
            child: const Text('Open Instagram'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePhoneCall(BuildContext context) async {
    final phone = business.phone;
    if (phone == null) return;
    Haptics.medium();
    final ok = await OutreachLauncher.openPhone(phone);
    if (!ok && context.mounted) {
      IosToast.show(context, 'Could not open phone');
    }
  }

  void _copyAndPromptManual(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    onCopy(message.content);
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(AppColors.surface, context),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(AppColors.border, context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                          AppColors.scoreGood, context)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(CupertinoIcons.checkmark_seal_fill,
                    color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context),
                    size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                'Message Generated',
                style: AppTypography.labelLarge(context).copyWith(
                  color: CupertinoDynamicColor.resolve(
                      AppColors.scoreGood, context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  AppColors.background, context),
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              border: Border.all(
                color: CupertinoDynamicColor.resolve(
                        AppColors.scoreGood, context)
                    .withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Text(
              message.content,
              style: AppTypography.bodyLarge(context).copyWith(
                height: 1.6,
                color: CupertinoDynamicColor.resolve(
                    AppColors.textSecondary, context),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Regenerate',
                  variant: AppButtonVariant.secondary,
                  onPressed: onRegenerate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Copy',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => onCopy(message.content),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildSendActions(context),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, duration: 400.ms, curve: Curves.easeOut);
  }

  List<Widget> _buildSendActions(BuildContext context) {
    switch (message.channel) {
      case OutreachChannel.whatsapp:
        return [
          AppButton(
            label: 'Open in WhatsApp',
            onPressed: () => _handleWhatsApp(context),
          ),
        ];
      case OutreachChannel.email:
        return [
          AppButton(
            label: 'Open in Mail',
            onPressed: () => _handleEmail(context),
          ),
        ];
      case OutreachChannel.instagram:
        return [
          AppButton(
            label: 'Open Instagram',
            onPressed: () => _handleInstagram(context),
          ),
        ];
      case OutreachChannel.phone:
        return [
          AppButton(
            label: business.phone == null ? 'No phone available' : 'Call',
            onPressed: business.phone == null
                ? null
                : () => _handlePhoneCall(context),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Copy script',
            variant: AppButtonVariant.secondary,
            onPressed: () => onCopy(message.content),
          ),
        ];
      case OutreachChannel.other:
        return [
          AppButton(
            label: 'Copy message',
            onPressed: () => onCopy(message.content),
          ),
        ];
    }
  }
}

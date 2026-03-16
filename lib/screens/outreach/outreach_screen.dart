import 'package:confetti/confetti.dart';
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
import '../../widgets/brutal_button.dart';
import '../../widgets/brutal_card.dart';
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
  late ConfettiController _confettiController;

  final List<String> _tones = ['professional', 'casual', 'direct'];
  static const _languages = {
    'en': 'English',
    'es': 'Espanol',
  };

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    // Default to user's preferred language
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    final lang = profile?.preferredLanguage;
    if (lang != null) {
      _selectedLanguage = lang;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
        _confettiController.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        Haptics.heavy();
        IosToast.show(context, 'Error: $e',
            icon: CupertinoIcons.exclamationmark_triangle);
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
    IosToast.show(context, 'Message copied to clipboard',
        icon: CupertinoIcons.check_mark);
  }

  void _regenerate(Business business) {
    Haptics.light();
    _generateMessage(business);
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Create Outreach'),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: businessAsync.when(
              data: (business) {
                if (business == null) {
                  return const Center(child: Text('Business not found'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Generate message for',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        business.name,
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Channel selector
                      Text(
                        'CHANNEL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
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
                      const SizedBox(height: 24),

                      // Tone selector
                      Text(
                        'TONE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
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
                      const SizedBox(height: 24),

                      // Language selector
                      Text(
                        'LANGUAGE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
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
                      const SizedBox(height: 32),

                      if (_generatedMessage == null && !_isGenerating)
                        _GradientCTA(
                          label: 'Generate Message',
                          icon: CupertinoIcons.sparkles,
                          onPressed: () => _generateMessage(business),
                        ),

                      if (_isGenerating) _GeneratingAnimation(),

                      if (_generatedMessage != null)
                        _MessageResult(
                          message: _generatedMessage!,
                          onCopy: _copyMessage,
                          onRegenerate: () => _regenerate(business),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              maxBlastForce: 12,
              minBlastForce: 4,
              gravity: 0.15,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.success,
                AppColors.secondary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Channel chip with gradient selected state
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
    final info = _getChannelInfo(channel);
    final color = info['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 0.5),
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
                  ? CupertinoColors.white
                  : AppColors.textTertiary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              info['name'] as String,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? CupertinoColors.white
                    : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getChannelInfo(OutreachChannel channel) {
    switch (channel) {
      case OutreachChannel.email:
        return {
          'name': 'Email',
          'icon': CupertinoIcons.mail,
          'color': AppColors.primary,
        };
      case OutreachChannel.whatsapp:
        return {
          'name': 'WhatsApp',
          'icon': CupertinoIcons.chat_bubble,
          'color': AppColors.success,
        };
      case OutreachChannel.instagram:
        return {
          'name': 'Instagram',
          'icon': CupertinoIcons.camera,
          'color': AppColors.secondary,
        };
      case OutreachChannel.phone:
        return {
          'name': 'Phone',
          'icon': CupertinoIcons.phone,
          'color': AppColors.info,
        };
      case OutreachChannel.other:
        return {
          'name': 'Other',
          'icon': CupertinoIcons.ellipsis,
          'color': AppColors.textSecondary,
        };
    }
  }
}

// Tone chip with gradient
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
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 0.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Text(
          tone[0].toUpperCase() + tone.substring(1),
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.background : AppColors.textPrimary,
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
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: AppColors.background),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.button
                    .copyWith(color: AppColors.background, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Generating animation with card
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
    return BrutalCard(
      padding: const EdgeInsets.all(24),
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
                          ? AppColors.secondary
                          : isDone
                              ? AppColors.success
                              : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[index],
                      style: AppTypography.bodyMedium.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : isDone
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
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
  final Function(String) onCopy;
  final VoidCallback onRegenerate;

  const _MessageResult({
    required this.message,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.sparkles,
                    color: AppColors.success, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                'Message Generated',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Text(
              message.content,
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: BrutalButton.secondary(
                  label: 'Regenerate',
                  icon: CupertinoIcons.arrow_2_circlepath,
                  onPressed: onRegenerate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrutalButton(
                  label: 'Copy',
                  icon: CupertinoIcons.doc_on_doc,
                  onPressed: () => onCopy(message.content),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, duration: 400.ms, curve: Curves.easeOut);
  }
}

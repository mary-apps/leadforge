import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/message.dart';
import '../../services/outreach_service.dart';
import '../../providers/businesses_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/brutal_button.dart';
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
  bool _isGenerating = false;
  Message? _generatedMessage;

  final List<String> _tones = ['professional', 'casual', 'direct'];

  Future<void> _generateMessage(Business business) async {
    // Check Pro status
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
        language: 'en',
      );

      if (mounted) {
        setState(() {
          _generatedMessage = message;
          _isGenerating = false;
        });
        Haptics.medium();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        Haptics.heavy();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXL),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Pro Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI message generation is a Pro feature.'),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Pro for:',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildBenefit('Unlimited AI messages'),
            _buildBenefit('4 outreach channels'),
            _buildBenefit('3 tone options'),
            _buildBenefit('Bilingual (EN/ES)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          BrutalButton(
            label: 'Upgrade to Pro',
            icon: Icons.workspace_premium,
            compact: true,
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Text(text, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    Haptics.medium();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Message copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _regenerate(Business business) {
    Haptics.light();
    _generateMessage(business);
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Outreach Message',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
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
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
                const SizedBox(height: 32),

                // Generate button or result
                if (_generatedMessage == null && !_isGenerating)
                  BrutalButton(
                    label: 'Generate Message',
                    icon: Icons.auto_awesome,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Channel selection chip
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              info['icon'] as IconData,
              color: isSelected ? AppColors.background : AppColors.textTertiary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              info['name'] as String,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.background
                    : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
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
        return {'name': 'Email', 'icon': Icons.email_outlined};
      case OutreachChannel.whatsapp:
        return {'name': 'WhatsApp', 'icon': Icons.chat_bubble_outline};
      case OutreachChannel.instagram:
        return {'name': 'Instagram', 'icon': Icons.photo_camera_outlined};
      case OutreachChannel.phone:
        return {'name': 'Phone', 'icon': Icons.phone_outlined};
      case OutreachChannel.other:
        return {'name': 'Other', 'icon': Icons.more_horiz};
    }
  }
}

/// Tone selection chip
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
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tone[0].toUpperCase() + tone.substring(1),
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected
                ? AppColors.background
                : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Generating animation
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusXL),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 24),
          ...List.generate(_steps.length, (index) {
            final isActive = index == _currentStep;
            final isDone = index < _currentStep;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: isActive
                        ? AppColors.primary
                        : isDone
                            ? AppColors.success
                            : AppColors.textTertiary,
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

/// Message result widget
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Message Generated',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Message content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppColors.radiusL),
            ),
            child: SelectableText(
              message.content,
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: BrutalButton.secondary(
                  label: 'Regenerate',
                  icon: Icons.refresh,
                  onPressed: onRegenerate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrutalButton(
                  label: 'Copy',
                  icon: Icons.copy,
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

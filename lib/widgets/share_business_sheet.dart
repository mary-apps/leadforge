import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../config/theme.dart';
import '../models/business.dart';
import '../utils/haptics.dart';
import 'brutal_button.dart';

/// Bottom sheet for sharing business details
class ShareBusinessSheet extends StatelessWidget {
  final Business business;
  
  const ShareBusinessSheet({
    super.key,
    required this.business,
  });
  
  static Future<void> show(BuildContext context, Business business) {
    Haptics.light();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBusinessSheet(business: business),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Share ${business.name}',
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how to share this lead',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Copy link
          BrutalButton(
            label: 'Copy Business Info',
            icon: Icons.copy,
            onPressed: () {
              _copyBusinessText(context);
            },
          ),
          const SizedBox(height: 12),

          // Share via system share sheet
          BrutalButton.success(
            label: 'Share via...',
            icon: Icons.share,
            onPressed: () {
              _shareViaSystem(context);
            },
          ),
          const SizedBox(height: 12),

          // Export as card (TODO: screenshot feature)
          BrutalButton.secondary(
            label: 'Export as Image',
            icon: Icons.image,
            onPressed: () {
              _showComingSoon(context);
            },
          ),
          const SizedBox(height: 24),
          
          // Cancel
          TextButton(
            onPressed: () {
              Haptics.light();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  void _copyBusinessText(BuildContext context) {
    final text = _formatBusinessText();
    
    Clipboard.setData(ClipboardData(text: text));
    Haptics.medium();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Business info copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _shareViaSystem(BuildContext context) async {
    final text = _formatBusinessText();
    
    Haptics.medium();
    Navigator.pop(context);
    
    try {
      await Share.share(
        text,
        subject: 'Lead: ${business.name}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
  
  void _showComingSoon(BuildContext context) {
    Haptics.light();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Coming soon in next update!'),
          ],
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }
  
  String _formatBusinessText() {
    final buffer = StringBuffer();
    
    buffer.writeln('🔥 NEW LEAD');
    buffer.writeln('');
    buffer.writeln('${business.statusBadge} ${business.name}');
    
    if (business.address != null) {
      buffer.writeln('📍 ${business.address}');
    }
    
    if (business.phone != null) {
      buffer.writeln('📞 ${business.phone}');
    }
    
    if (business.website != null) {
      buffer.writeln('🌐 ${business.website}');
    } else {
      buffer.writeln('🌐 No website');
    }
    
    if (business.rating != null) {
      buffer.writeln('⭐ ${business.rating}/5.0 (${business.reviewsCount} reviews)');
    }
    
    if (business.auditScore != null) {
      buffer.writeln('');
      buffer.writeln('AUDIT SCORE: ${business.auditScore}/100');
      
      if (business.auditDiagnosis != null) {
        buffer.writeln('');
        buffer.writeln('AI ANALYSIS:');
        buffer.writeln(business.auditDiagnosis);
      }
    }
    
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('Shared from LeadForge 🚀');
    
    return buffer.toString();
  }
}

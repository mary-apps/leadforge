import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/audit_result.dart';
import '../../services/audit_service.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/score_gauge.dart';

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final String businessId;
  
  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  @override
  ConsumerState<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends ConsumerState<BusinessDetailScreen> {
  bool _isAuditing = false;
  AuditResult? _auditResult;
  
  Future<void> _runAudit(Business business) async {
    setState(() => _isAuditing = true);
    
    try {
      await Future.delayed(const Duration(seconds: 2)); // Build suspense
      final result = await AuditService.auditBusiness(business.id);
      
      if (mounted) {
        setState(() {
          _auditResult = result;
          _isAuditing = false;
        });
        
        // Refresh business data
        ref.refresh(businessProvider(widget.businessId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessProvider(widget.businessId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Detail'),
      ),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Business not found'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(business.statusBadge, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                business.name,
                                style: AppTypography.titleLarge,
                              ),
                            ),
                          ],
                        ),
                        if (business.address != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            business.address!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (business.rating != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${business.rating} (${business.reviewsCount} reviews)',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Audit section
                if (!business.isAudited && !_isAuditing)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _runAudit(business),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze Business'),
                    ),
                  ),
                
                if (_isAuditing)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Analyzing with AI...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (business.isAudited || _auditResult != null) ...[
                  // Score gauge
                  ScoreGauge(
                    score: _auditResult?.score ?? business.auditScore ?? 0,
                  ),
                  const SizedBox(height: 24),
                  
                  // Diagnosis
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis',
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _auditResult?.diagnosis ?? business.auditDiagnosis ?? '',
                            style: AppTypography.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // CTAs
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to Build Demo screen
                          },
                          child: const Text('Generate Demo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to Outreach screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          child: const Text('Create Message'),
                        ),
                      ),
                    ],
                  ),
                ],
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

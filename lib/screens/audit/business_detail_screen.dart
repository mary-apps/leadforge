import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../models/audit_result.dart';
import '../../services/audit_service.dart';
import '../../providers/businesses_provider.dart';
import '../../widgets/animated_score_gauge.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/share_business_sheet.dart';
import '../../utils/haptics.dart';

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
        actions: [
          if (businessAsync.value != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ShareBusinessSheet.show(context, businessAsync.value!);
              },
            ),
        ],
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
                    child: AnimatedButton.primary(
                      onPressed: () => _runAudit(business),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.analytics),
                          SizedBox(width: 8),
                          Text('Analyze Business'),
                        ],
                      ),
                    ),
                  ),
                
                if (_isAuditing)
                  _AnalyzingAnimation(),
                
                if (business.isAudited || _auditResult != null) ...[
                  // Score gauge (animated)
                  AnimatedScoreGauge(
                    score: _auditResult?.score ?? business.auditScore ?? 0,
                    onComplete: () => Haptics.medium(),
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
                        child: AnimatedButton.primary(
                          onPressed: () {
                            context.push('/business/${business.id}/build-demo');
                          },
                          child: const Text('Generate Demo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedButton(
                          onPressed: () {
                            context.push('/business/${business.id}/outreach');
                          },
                          backgroundColor: AppColors.success,
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

/// Widget que muestra animación de análisis paso a paso
class _AnalyzingAnimation extends StatefulWidget {
  @override
  State<_AnalyzingAnimation> createState() => _AnalyzingAnimationState();
}

class _AnalyzingAnimationState extends State<_AnalyzingAnimation> {
  int _currentStep = 0;
  
  final List<String> _steps = [
    'Checking website...',
    'Analyzing reviews...',
    'Calculating score...',
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
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          ...List.generate(_steps.length, (index) {
            final isActive = index == _currentStep;
            final isDone = index < _currentStep;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDone ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: isActive
                        ? AppColors.primary
                        : isDone
                            ? AppColors.success
                            : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _steps[index],
                    style: AppTypography.bodyMedium.copyWith(
                      color: isActive
                          ? AppColors.textPrimary
                          : isDone
                              ? AppColors.textSecondary
                              : AppColors.textTertiary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

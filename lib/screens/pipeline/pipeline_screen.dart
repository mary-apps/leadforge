import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/business.dart';
import '../../providers/businesses_provider.dart';

class PipelineScreen extends ConsumerWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(pipelineProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipeline'),
      ),
      body: pipelineAsync.when(
        data: (pipeline) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(context, ref, 'Found', BusinessStatus.found, pipeline[BusinessStatus.found] ?? []),
              _buildSection(context, ref, 'Audited', BusinessStatus.audited, pipeline[BusinessStatus.audited] ?? []),
              _buildSection(context, ref, 'Demo Created', BusinessStatus.demoCreated, pipeline[BusinessStatus.demoCreated] ?? []),
              _buildSection(context, ref, 'Contacted', BusinessStatus.contacted, pipeline[BusinessStatus.contacted] ?? []),
              _buildSection(context, ref, 'Interested', BusinessStatus.interested, pipeline[BusinessStatus.interested] ?? []),
              _buildSection(context, ref, 'Closed', BusinessStatus.closed, pipeline[BusinessStatus.closed] ?? []),
              _buildSection(context, ref, 'Lost', BusinessStatus.lost, pipeline[BusinessStatus.lost] ?? []),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    BusinessStatus status,
    List<Business> businesses,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(title, style: AppTypography.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                businesses.length.toString(),
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        children: businesses.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No businesses in this stage',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ]
            : businesses.map((business) {
                return ListTile(
                  leading: Text(business.statusBadge),
                  title: Text(business.name),
                  subtitle: business.shortAddress != null
                      ? Text(business.shortAddress!)
                      : null,
                  trailing: business.auditScore != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.scoreColor(business.auditScore!)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            business.auditScore.toString(),
                            style: AppTypography.mono.copyWith(
                              color: AppColors.scoreColor(business.auditScore!),
                            ),
                          ),
                        )
                      : null,
                  onTap: () => context.push('/business/${business.id}'),
                );
              }).toList(),
      ),
    );
  }
}

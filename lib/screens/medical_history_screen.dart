import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/card_actions.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_header.dart';
import 'add_record_sheet.dart';
import '../widgets/empty_state.dart';
import '../data/care_store.dart';

class MedicalHistoryScreen extends StatelessWidget {
  final String? personId;
  final bool showHeader;
  final bool canEdit;
  final VoidCallback? onChanged; // called after an edit or delete so the parent refreshes
  const MedicalHistoryScreen({
    super.key,
    this.personId,
    this.showHeader = true,
    this.canEdit = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final records = mockRecords
        .where((r) => personId == null || r.personId == personId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const PageHeader(
            title: 'Medical History',
            subtitle: 'Every health record, in one safe place',
          ),
        Expanded(
          child: (recordsStore.loading && mockRecords.isEmpty)
              ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
              : (recordsStore.error != null && mockRecords.isEmpty)
                  ? EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Something went wrong',
                      message: recordsStore.error!,
                      actionLabel: 'TRY AGAIN',
                      actionIcon: Icons.refresh_rounded,
                      onAction: recordsStore.load,
                    )
                  : records.isEmpty                            ? EmptyState(
                  icon: Icons.history_edu_rounded,
                  title: 'No medical history yet',
                  message: canEdit
                      ? 'Tap "ADD MEDICAL RECORD" above to log a diagnosis, treatment or prescription.'
                      : 'Your caregiver has not added any records yet.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (_, i) {
                    final r = records[i];
                    return _RecordCard(
                      r: r,
                      onEdit: canEdit
                          ? () => showAddRecordSheet(
                              context, r.personId, () => onChanged?.call(),
                              existing: r)
                          : null,
                                            onDelete: canEdit
                          ? () async {
                              if (!await confirmDelete(context, 'this record')) return;
                              try {
                                await recordsStore.delete(r.id);
                                onChanged?.call();
                              } catch (e) {
                                debugPrint('Deleting record failed: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Could not delete. Please try again.',
                                          style: AppTheme.body(14, color: AppColors.sand))));
                                }
                              }
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MedicalRecord r;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _RecordCard({required this.r, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: AppColors.maroon, shape: BoxShape.circle),
                child: const Icon(Icons.description_rounded, size: 18, color: AppColors.sand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Medical Record',
                    style: AppTheme.body(15, color: AppColors.maroon, weight: FontWeight.w700)),
              ),
              Text(DateFormat('MMM d, y').format(r.date),
                  style: AppTheme.body(12.5, weight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 20),
          Text('DIAGNOSIS', style: AppTheme.label()),
          const SizedBox(height: 4),
          Text(r.diagnosis, style: AppTheme.heading(19, color: AppColors.text)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Field(label: 'PHYSICIAN', value: r.physician)),
              const SizedBox(width: 12),
              Expanded(child: _Field(label: 'TREATMENT', value: r.treatment, maxLines: 3)),
            ],
          ),
          if (r.prescription != null) ...[
            const Divider(height: 30, color: Colors.white54),
            Row(children: [
              const Icon(Icons.medication_rounded, size: 16, color: AppColors.maroon),
              const SizedBox(width: 6),
              Text('PRESCRIPTION',
                  style: AppTheme.label().copyWith(color: AppColors.maroon)),
            ]),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(r.prescription!,
                  style: AppTheme.body(14).copyWith(fontStyle: FontStyle.italic)),
            ),
          ],
          if (onEdit != null && onDelete != null) ...[
            const Divider(height: 28, color: Colors.white54),
            CardActions(onEdit: onEdit!, onDelete: onDelete!),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  const _Field({required this.label, required this.value, this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.label()),
        const SizedBox(height: 2),
        Text(value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body(14, weight: FontWeight.w600)),
      ],
    );
  }
}
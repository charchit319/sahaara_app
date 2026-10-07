import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_header.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Medical History',
          subtitle: 'Every health record, in one safe place',
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
            itemCount: mockRecords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (_, i) => _RecordCard(r: mockRecords[i]),
          ),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MedicalRecord r;
  const _RecordCard({required this.r});

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

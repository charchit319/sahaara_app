import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahaara_app/widgets/card_actions.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_header.dart';
import '../widgets/status_chip.dart';
import 'add_visit_sheet.dart';
import '../widgets/empty_state.dart';
import '../data/care_store.dart';


class AppointmentsScreen extends StatefulWidget {
  /// null = visits of everyone (caregiver tab); otherwise one person's visits.
  final String? personId;
  final bool showHeader;
  final bool canEdit; // show Edit / Delete on each card
  const AppointmentsScreen({
    super.key,
    this.personId,
    this.showHeader = true,
    this.canEdit = false,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _showUpcoming = true;

    @override
  void initState() {
    super.initState();
    visitsStore.addListener(_refresh);
  }

  @override
  void dispose() {
    visitsStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }
  

    Future<void> _delete(Appointment a) async {
    if (!await confirmDelete(context, 'this visit')) return;
    try {
      await visitsStore.delete(a.id);
    } catch (e) {
      debugPrint('Deleting visit failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not delete. Please try again.',
                style: AppTheme.body(14, color: AppColors.sand))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = mockAppointments
        .where((a) =>
            a.isUpcoming == _showUpcoming &&
            (widget.personId == null || a.personId == widget.personId))
        .toList()
      ..sort((a, b) => _showUpcoming
          ? a.dateTime.compareTo(b.dateTime)
          : b.dateTime.compareTo(a.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          const PageHeader(
            title: 'Hospital Visits',
            subtitle: 'Upcoming and past visits for everyone you look after',
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _Toggle(
            upcoming: _showUpcoming,
            onChanged: (v) => setState(() => _showUpcoming = v),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
                    child: (visitsStore.loading && mockAppointments.isEmpty)
              ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
              : (visitsStore.error != null && mockAppointments.isEmpty)
                  ? EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Something went wrong',
                      message: visitsStore.error!,
                      actionLabel: 'TRY AGAIN',
                      actionIcon: Icons.refresh_rounded,
                      onAction: visitsStore.load,
                    )
                  : list.isEmpty
              ? EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: _showUpcoming ? 'No upcoming visits' : 'No past visits',
                  message: widget.personId == null
                      ? 'Visits you add for the people in your care will show up here.'
                      : (widget.canEdit
                          ? 'Tap "ADD HOSPITAL VISIT" above to schedule or log a visit.'
                          : 'Visits added by your caregiver will appear here.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (_, i) {
                    final a = list[i];
                    return _AppointmentCard(
                      a: a,
                      showPerson: widget.personId == null,
                      onEdit: widget.canEdit
                          ? () => showAddVisitSheet(
                              context, a.personId, () => setState(() {}),
                              existing: a)
                          : null,
                      onDelete: widget.canEdit ? () => _delete(a) : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool upcoming;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.upcoming, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool value) {
      final selected = upcoming == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.maroon : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(label,
                  style: AppTheme.body(14,
                      color: selected ? AppColors.sand : AppColors.brown,
                      weight: FontWeight.w700)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
      ),
      child: Row(children: [tab('Upcoming', true), tab('Past Visits', false)]),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment a;
  final bool showPerson;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _AppointmentCard({
    required this.a,
    this.showPerson = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: a.isUpcoming ? 1 : 0.8,
      child: GlassCard(
        radius: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppColors.maroon),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(DateFormat('EEE, MMM d, y').format(a.dateTime),
                              style: AppTheme.body(16,
                                  color: AppColors.maroon, weight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Text(DateFormat('hh:mm a').format(a.dateTime),
                            style: AppTheme.body(13, weight: FontWeight.w500)),
                      ]),
                    ],
                  ),
                ),
                StatusChip(upcoming: a.isUpcoming),
              ],
            ),
            const SizedBox(height: 18),
            if (showPerson) ...[
              _LabelValue(
                  icon: Icons.favorite_border_rounded,
                  label: 'PATIENT',
                  value: personName(a.personId)),
              const SizedBox(height: 12),
            ],
            _LabelValue(icon: Icons.person_outline_rounded, label: 'DOCTOR', value: a.doctor),
            const SizedBox(height: 12),
            _LabelValue(
                icon: Icons.location_on_outlined, label: 'INSTITUTION', value: a.institution),
            const Divider(height: 28, color: Colors.white54),
            Text('REASON FOR VISIT', style: AppTheme.label()),
            const SizedBox(height: 4),
            Text(a.problem, style: AppTheme.body(14)),
            if (a.prescription != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.maroon.withOpacity(0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRESCRIPTION',
                        style: AppTheme.label().copyWith(color: AppColors.maroon)),
                    const SizedBox(height: 4),
                    Text(a.prescription!,
                        style: AppTheme.body(14).copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
            if (onEdit != null && onDelete != null) ...[
              const Divider(height: 24, color: Colors.white54),
              CardActions(onEdit: onEdit!, onDelete: onDelete!),
            ],
          ],
        ),
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _LabelValue({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: AppColors.brown),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.label()),
              Text(value, style: AppTheme.body(14.5, weight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

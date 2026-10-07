import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_header.dart';
import '../widgets/status_chip.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    final list = mockAppointments.where((a) => a.isUpcoming == _showUpcoming).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'My Appointments',
          subtitle: 'Manage your healthcare visits and schedules',
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
          child: list.isEmpty
              ? const _Empty()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (_, i) => _AppointmentCard(a: list[i]),
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
  const _AppointmentCard({required this.a});

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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 52, color: AppColors.maroon.withOpacity(0.4)),
          const SizedBox(height: 10),
          Text('No appointments found', style: AppTheme.body(16, weight: FontWeight.w600)),
          Text('Your scheduled visits will appear here.',
              style: AppTheme.body(13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

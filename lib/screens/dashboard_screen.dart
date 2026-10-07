import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/ribbon.dart';

/// Home tab. [onNavigate] switches the bottom-bar tab
/// (0 Home, 1 Visits, 2 Records, 3 Contact).
class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _patient = 0;
  final Set<int> _taken = {0};

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _soon(String what) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$what — coming soon', style: AppTheme.body(14, color: AppColors.sand))),
      );

  @override
  Widget build(BuildContext context) {
    final upcoming = mockAppointments.where((a) => a.isUpcoming).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final next = upcoming.isEmpty ? null : upcoming.first;
    final patient = mockPatients[_patient];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        _header(),
        const SizedBox(height: 26),

        _sectionTitle('My Patients', 'See all', () => _soon('Patients list')),
        const SizedBox(height: 12),
        _patients(),
        const SizedBox(height: 26),

        if (next != null) ...[
          _nextAppointment(next),
          const SizedBox(height: 18),
        ],

        _stats(upcoming.length),
        const SizedBox(height: 26),

        _sectionTitle("Today's medication · ${patient.name}", null, null),
        const SizedBox(height: 12),
        _medications(),
        const SizedBox(height: 26),

        _sectionTitle('Quick actions', null, null),
        const SizedBox(height: 12),
        _quickActions(),
        const SizedBox(height: 26),

        _sectionTitle('Recent records', 'View all', () => widget.onNavigate(2)),
        const SizedBox(height: 12),
        ...mockRecords.take(2).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _recordTile(r),
            )),
        const SizedBox(height: 14),
        _tip(),
      ],
    );
  }

  // ───────── header ─────────
  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting.toUpperCase(),
                  style: AppTheme.label().copyWith(color: AppColors.tan)),
              const SizedBox(height: 6),
              Text('Welcome back,\n$mockUserName', style: AppTheme.heading(32)),
              const SizedBox(height: 8),
              Text("Here's how your family's care looks today.",
                  style: AppTheme.body(14, color: AppColors.tan)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _soon('Notifications'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.maroon),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cream, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String? action, VoidCallback? onTap) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(color: AppColors.maroon, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppTheme.heading(19))),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: AppTheme.body(13, color: AppColors.brown, weight: FontWeight.w700)),
          ),
      ],
    );
  }

  // ───────── patients ─────────
  Widget _patients() {
    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: mockPatients.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == mockPatients.length) return _addPatientCard();
          final p = mockPatients[i];
          final sel = i == _patient;
          return GestureDetector(
            onTap: () => setState(() => _patient = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? AppColors.maroon : Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: sel ? AppColors.maroon : Colors.white.withOpacity(0.8)),
                boxShadow: sel
                    ? [BoxShadow(color: AppColors.maroon.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: sel ? AppColors.sand : AppColors.maroon.withOpacity(0.1),
                    child: Text(p.name[0],
                        style: AppTheme.heading(18, color: AppColors.maroon)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: AppTheme.body(15,
                              color: sel ? AppColors.sand : AppColors.text,
                              weight: FontWeight.w700)),
                      Text('${p.relation} · ${p.age}',
                          style: AppTheme.body(12,
                              color: sel ? AppColors.sand.withOpacity(0.75) : AppColors.tan)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _addPatientCard() {
    return GestureDetector(
      onTap: () => _soon('Add patient'),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.maroon.withOpacity(0.5), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.maroon, size: 30),
            const SizedBox(height: 6),
            Text('Add patient',
                style: AppTheme.body(12.5, color: AppColors.maroon, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ───────── next appointment ─────────
  Widget _nextAppointment(Appointment a) {
    final days = a.dateTime.difference(DateTime.now()).inDays;
    final when = days <= 0 ? 'Today' : (days == 1 ? 'Tomorrow' : 'In $days days');

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 22, 40, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.maroon, AppColors.maroonDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('NEXT APPOINTMENT',
                        style: AppTheme.label().copyWith(color: AppColors.sand.withOpacity(0.7))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(when,
                          style: AppTheme.body(11.5,
                              color: AppColors.maroon, weight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(DateFormat('EEE, MMM d').format(a.dateTime),
                    style: AppTheme.heading(28, color: AppColors.sand)),
                Text(DateFormat('hh:mm a').format(a.dateTime),
                    style: AppTheme.body(14, color: AppColors.sand.withOpacity(0.8))),
                const SizedBox(height: 16),
                Row(children: [
                  Icon(Icons.person_outline_rounded, size: 16, color: AppColors.sand.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text(a.doctor, style: AppTheme.body(14, color: AppColors.sand, weight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.sand.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a.institution,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(13.5, color: AppColors.sand.withOpacity(0.85))),
                  ),
                ]),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => widget.onNavigate(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.sand),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View all visits',
                            style: AppTheme.body(13.5, color: AppColors.sand, weight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.sand),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dhaka ribbon edge
          const Positioned(right: 0, top: 0, bottom: 0, width: 18, child: Ribbon()),
        ],
      ),
    );
  }

  // ───────── stats ─────────
  Widget _stats(int upcomingCount) {
    Widget stat(IconData icon, String value, String label) => Expanded(
          child: GlassCard(
            radius: 28,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(icon, color: AppColors.brown, size: 22),
                const SizedBox(height: 6),
                Text(value, style: AppTheme.heading(24)),
                Text(label,
                    textAlign: TextAlign.center,
                    style: AppTheme.body(11.5, color: AppColors.tan)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        stat(Icons.event_available_rounded, '$upcomingCount', 'Upcoming\nvisits'),
        const SizedBox(width: 12),
        stat(Icons.medication_rounded, '${mockMedications.length}', 'Doses\ntoday'),
        const SizedBox(width: 12),
        stat(Icons.folder_rounded, '${mockRecords.length}', 'Records\nstored'),
      ],
    );
  }

  // ───────── medications ─────────
  Widget _medications() {
    final done = _taken.length;
    final total = mockMedications.length;
    return GlassCard(
      radius: 36,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Text('$done of $total taken',
                  style: AppTheme.body(13.5, color: AppColors.maroon, weight: FontWeight.w700)),
              const SizedBox(width: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: done / total,
                    minHeight: 7,
                    backgroundColor: AppColors.maroon.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.maroon),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(mockMedications.length, (i) {
            final m = mockMedications[i];
            final taken = _taken.contains(i);
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => taken ? _taken.remove(i) : _taken.add(i)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(m.time,
                          style: AppTheme.body(12.5, color: AppColors.brown, weight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: AppTheme.body(14.5, weight: FontWeight.w700).copyWith(
                                  decoration: taken ? TextDecoration.lineThrough : null)),
                          Text(m.dose, style: AppTheme.body(12.5, color: AppColors.tan)),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: taken ? AppColors.maroon : Colors.transparent,
                        border: Border.all(color: AppColors.maroon, width: 1.5),
                      ),
                      child: taken
                          ? const Icon(Icons.check_rounded, size: 16, color: AppColors.sand)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ───────── quick actions ─────────
  Widget _quickActions() {
    Widget action(IconData icon, String label, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.maroon.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.sand, size: 24),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: AppTheme.body(12, weight: FontWeight.w600)),
              ],
            ),
          ),
        );

    return GlassCard(
      radius: 36,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        children: [
          action(Icons.add_task_rounded, 'Book\nvisit', () => widget.onNavigate(1)),
          action(Icons.note_add_rounded, 'Add\nrecord', () => widget.onNavigate(2)),
          action(Icons.person_add_alt_1_rounded, 'Add\npatient', () => _soon('Add patient')),
          action(Icons.group_add_rounded, 'Invite\nfamily', () => _soon('Invite family')),
        ],
      ),
    );
  }

  // ───────── records ─────────
  Widget _recordTile(MedicalRecord r) {
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(16),
      onTap: () => widget.onNavigate(2),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
            child: const Icon(Icons.description_rounded, color: AppColors.sand, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.diagnosis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(14.5, weight: FontWeight.w700)),
                Text('${r.physician} · ${DateFormat('MMM d, y').format(r.date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(12.5, color: AppColors.tan)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.tan),
        ],
      ),
    );
  }

  // ───────── tip ─────────
  Widget _tip() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.maroon, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Care tip: a ten-minute chat over tea does as much for the heart as any prescription.',
              style: AppTheme.heading(14.5, color: AppColors.brown)
                  .copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

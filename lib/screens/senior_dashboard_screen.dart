import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/ribbon.dart';

/// The person's own home screen: calm, large text, read-only.
/// Everything here was filled in by their caregiver.
class SeniorDashboardScreen extends StatefulWidget {
  final Person person;
  final ValueChanged<int> onNavigate; // 0 Home, 1 My Record, 2 Contact
  const SeniorDashboardScreen({super.key, required this.person, required this.onNavigate});

  @override
  State<SeniorDashboardScreen> createState() => _SeniorDashboardScreenState();
}

class _SeniorDashboardScreenState extends State<SeniorDashboardScreen> {
  final Set<int> _taken = {};

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.person;
    final caregivers = (mockAccess[p.id] ?? []).where((m) => m.role == 'Caregiver').toList();
    final meds = mockMedications.where((m) => m.personId == p.id).toList();
    final upcoming = mockAppointments.where((a) => a.personId == p.id && a.isUpcoming).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final next = upcoming.isEmpty ? null : upcoming.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      children: [
        Text(_greeting.toUpperCase(), style: AppTheme.label().copyWith(color: AppColors.tan, fontSize: 13)),
        const SizedBox(height: 6),
        Text('Hello, ${p.name}', style: AppTheme.heading(38)),
        const SizedBox(height: 22),

        // who looks after me
        if (caregivers.isNotEmpty)
          GlassCard(
            radius: 36,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.maroon,
                  child: Text(caregivers.first.name[0],
                      style: AppTheme.heading(24, color: AppColors.sand)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Looked after by', style: AppTheme.body(14, color: AppColors.tan)),
                      Text(caregivers.first.name, style: AppTheme.heading(22)),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.maroon,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Calling ${caregivers.first.name}… (prototype)',
                            style: AppTheme.body(15, color: AppColors.sand)))),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.call_rounded, color: AppColors.sand, size: 26),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),

        // next visit
                // next visit
        if (next != null)
          _nextVisit(next)
        else
          GlassCard(
            radius: 36,
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const Icon(Icons.event_available_rounded, color: AppColors.maroon, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text('No hospital visits planned',
                    style: AppTheme.body(17, weight: FontWeight.w600)),
              ),
            ]),
          ),
        const SizedBox(height: 22),

        // medication
        Text("Today's medicines", style: AppTheme.heading(24)),
        const SizedBox(height: 12),
        if (meds.isEmpty)
          Text('Nothing to take today.', style: AppTheme.body(16, color: AppColors.tan))
        else
          ...List.generate(meds.length, (i) {
            final m = meds[i];
            final done = _taken.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                radius: 30,
                padding: const EdgeInsets.all(18),
                onTap: () => setState(() => done ? _taken.remove(i) : _taken.add(i)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.time,
                              style: AppTheme.body(15, color: AppColors.brown, weight: FontWeight.w800)),
                          Text(m.name,
                              style: AppTheme.body(19, weight: FontWeight.w700).copyWith(
                                  decoration: done ? TextDecoration.lineThrough : null)),
                          Text(m.dose, style: AppTheme.body(14.5, color: AppColors.tan)),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppColors.maroon : Colors.transparent,
                        border: Border.all(color: AppColors.maroon, width: 2),
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded, color: AppColors.sand, size: 26)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 14),

        // shortcuts
        Text('My record', style: AppTheme.heading(24)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _shortcut(Icons.history_edu_rounded, 'Medical\nhistory', false)),
          const SizedBox(width: 12),
          Expanded(child: _shortcut(Icons.local_hospital_rounded, 'Hospital\nvisits', false)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _shortcut(Icons.description_rounded, 'Documents', false)),
          const SizedBox(width: 12),
          Expanded(child: _shortcut(Icons.biotech_rounded, 'X-rays &\nscans', true)),
        ]),
      ],
    );
  }

  Widget _nextVisit(Appointment a) {
    final days = a.dateTime.difference(DateTime.now()).inDays;
    final when = days <= 0 ? 'Today' : (days == 1 ? 'Tomorrow' : 'In $days days');
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 22, 42, 22),
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
                Text('NEXT HOSPITAL VISIT',
                    style: AppTheme.label().copyWith(color: AppColors.sand.withOpacity(0.75), fontSize: 12)),
                const SizedBox(height: 10),
                Text(when, style: AppTheme.heading(32, color: AppColors.sand)),
                const SizedBox(height: 4),
                Text(
                    '${DateFormat('EEEE, MMM d').format(a.dateTime)} · ${DateFormat('hh:mm a').format(a.dateTime)}',
                    style: AppTheme.body(16, color: AppColors.sand)),
                const SizedBox(height: 12),
                Text(a.doctor,
                    style: AppTheme.body(17, color: AppColors.sand, weight: FontWeight.w700)),
                Text(a.institution,
                    style: AppTheme.body(14.5, color: AppColors.sand.withOpacity(0.85))),
              ],
            ),
          ),
          const Positioned(right: 0, top: 0, bottom: 0, width: 18, child: Ribbon()),
        ],
      ),
    );
  }

  Widget _shortcut(IconData icon, String label, bool dark) {
    final child = Column(
      children: [
        Icon(icon, size: 34, color: dark ? AppColors.scanAccent : AppColors.maroon),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: AppTheme.body(15, color: dark ? Colors.white : AppColors.text, weight: FontWeight.w700)),
      ],
    );
    if (dark) {
      return GestureDetector(
        onTap: () => widget.onNavigate(1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.scanDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.scanAccent.withOpacity(0.3)),
          ),
          child: child,
        ),
      );
    }
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(vertical: 20),
      onTap: () => widget.onNavigate(1),
      child: child,
    );
  }
}

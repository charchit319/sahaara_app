import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/ribbon.dart';
import 'people_screen.dart';
import 'person_record_screen.dart';
import '../config.dart';
import '../widgets/empty_state.dart';
import '../data/people_store.dart';
import '../data/care_store.dart';

/// Caregiver home. Everything below the patient list follows the selected person.
/// [onNavigate] switches the bottom-bar tab (0 Home, 1 People, 2 Visits, 3 Contact).
class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selected = 0;
final Set<String> _taken = {}; // "personId-index"
  @override
  void initState() {
    super.initState();
    peopleStore.addListener(_refresh);
    visitsStore.addListener(_refresh);
    recordsStore.addListener(_refresh);
  }

  @override
  void dispose() {
    peopleStore.removeListener(_refresh);
    visitsStore.removeListener(_refresh);
    recordsStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _soon(String what) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$what — coming soon', style: AppTheme.body(14, color: AppColors.sand))),
      );

  Future<void> _open(Person p, RecordSection section) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PersonRecordScreen(person: p, initial: section)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
        if (peopleStore.loading && mockPeople.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
    }
    if (peopleStore.error != null && mockPeople.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: peopleStore.error!,
        actionLabel: 'TRY AGAIN',
        actionIcon: Icons.refresh_rounded,
        onAction: peopleStore.load,
      );
    }
        if (mockPeople.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [
          _header(),
          const SizedBox(height: 40),
          EmptyState(
            icon: Icons.groups_rounded,
            title: 'Add the first person you look after',
            message:
                'Each person gets their own record for visits, medical history and documents.',
            actionLabel: 'ADD PERSON',
            onAction: () => showAddPersonSheet(context, () => setState(() {})),
          ),
        ],
      );
    }
    if (_selected >= mockPeople.length) _selected = 0;
    final person = mockPeople[_selected];

    final upcoming = mockAppointments
        .where((a) => a.personId == person.id && a.isUpcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final next = upcoming.isEmpty ? null : upcoming.first;
    final meds = mockMedications.where((m) => m.personId == person.id).toList();
    final records = mockRecords.where((r) => r.personId == person.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        _header(),
        const SizedBox(height: 26),

        _sectionTitle('People in your care', 'See all', () => widget.onNavigate(1)),
        const SizedBox(height: 12),
        _people(),
        const SizedBox(height: 14),
        _openRecordButton(person),
        const SizedBox(height: 26),

        _nextAppointment(person, next),
        const SizedBox(height: 18),

        _stats(person, upcoming.length, meds.length),
        const SizedBox(height: 26),

        _sectionTitle("Today's medication · ${person.name}", null, null),
        const SizedBox(height: 12),
        _medications(person, meds),
        const SizedBox(height: 26),

        _sectionTitle('Quick actions', null, null),
        const SizedBox(height: 12),
        _quickActions(person),
        const SizedBox(height: 26),

        _sectionTitle('Recent records · ${person.name}', 'View all',
            () => _open(person, RecordSection.history)),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Text('No medical records yet.', style: AppTheme.body(14, color: AppColors.muted))
        else
          ...records.take(2).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _recordTile(person, r),
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
              Text('Welcome back,\n$userName', style: AppTheme.heading(32)),
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

  // ───────── people ─────────
  Widget _people() {
    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: mockPeople.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == mockPeople.length) return _addPersonCard();
          final p = mockPeople[i];
          final sel = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
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
                    child: Text(p.name[0], style: AppTheme.heading(18, color: AppColors.maroon)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: AppTheme.body(15,
                              color: sel ? AppColors.sand : AppColors.text,
                              weight: FontWeight.w700)),
                      Text(p.subtitle,
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

  Widget _addPersonCard() {
    return GestureDetector(
      onTap: () => showAddPersonSheet(context, () => setState(() {})),
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
            Text('Add person',
                style: AppTheme.body(12.5, color: AppColors.maroon, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _openRecordButton(Person p) {
    return GestureDetector(
      onTap: () => _open(p, RecordSection.overview),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.maroon.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_shared_rounded, color: AppColors.maroon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text("Open ${p.name}'s full record",
                  style: AppTheme.body(14, color: AppColors.maroon, weight: FontWeight.w700)),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.maroon, size: 18),
          ],
        ),
      ),
    );
  }

  // ───────── next appointment ─────────
  Widget _nextAppointment(Person p, Appointment? a) {
    if (a == null) {
      return GlassCard(
        radius: 36,
        child: Row(
          children: [
            const Icon(Icons.event_available_rounded, color: AppColors.maroon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text('No upcoming hospital visit for ${p.name}.',
                  style: AppTheme.body(14.5, weight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => _open(p, RecordSection.visits),
              child: Text('Add', style: AppTheme.body(14, color: AppColors.maroon, weight: FontWeight.w800)),
            ),
          ],
        ),
      );
    }

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
                    Expanded(
                      child: Text('NEXT VISIT · ${p.name.toUpperCase()}',
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.label().copyWith(color: AppColors.sand.withOpacity(0.7))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(when,
                          style: AppTheme.body(11.5, color: AppColors.maroon, weight: FontWeight.w800)),
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
                  onTap: () => widget.onNavigate(2),
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
          const Positioned(right: 0, top: 0, bottom: 0, width: 18, child: Ribbon()),
        ],
      ),
    );
  }

  // ───────── stats ─────────
  Widget _stats(Person p, int upcomingCount, int doses) {
    final docs = mockDocuments.where((d) => d.personId == p.id).length;
    final scans = mockScans.where((s) => s.personId == p.id).length;

    Widget stat(IconData icon, String value, String label, {bool dark = false}) => Expanded(
          child: GestureDetector(
            onTap: dark || label.startsWith('Docs')
                ? () => _open(p, RecordSection.documents)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: dark ? AppColors.scanDark : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: dark ? AppColors.scanAccent.withOpacity(0.3) : Colors.white.withOpacity(0.7)),
              ),
              child: Column(
                children: [
                  Icon(icon, color: dark ? AppColors.scanAccent : AppColors.brown, size: 22),
                  const SizedBox(height: 6),
                  Text(value, style: AppTheme.heading(24, color: dark ? Colors.white : AppColors.maroon)),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: AppTheme.body(11.5, color: dark ? AppColors.scanAccent : AppColors.tan)),
                ],
              ),
            ),
          ),
        );

    return Row(
      children: [
        stat(Icons.event_available_rounded, '$upcomingCount', 'Upcoming\nvisits'),
        const SizedBox(width: 10),
        stat(Icons.description_rounded, '$docs', 'Docs\nstored'),
        const SizedBox(width: 10),
        stat(Icons.biotech_rounded, '$scans', 'X-rays &\nscans', dark: true),
      ],
    );
  }

  // ───────── medications ─────────
  Widget _medications(Person p, List<Medication> meds) {
    if (meds.isEmpty) {
      return GlassCard(
        radius: 36,
        child: Text('No medication added for ${p.name} yet.',
            style: AppTheme.body(14, color: AppColors.muted)),
      );
    }
    final done = List.generate(meds.length, (i) => i).where((i) => _taken.contains('${p.id}-$i')).length;
    final total = meds.length;
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
          ...List.generate(meds.length, (i) {
            final m = meds[i];
            final key = '${p.id}-$i';
            final taken = _taken.contains(key);
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => taken ? _taken.remove(key) : _taken.add(key)),
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
  Widget _quickActions(Person p) {
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
          action(Icons.add_task_rounded, 'Add\nvisit', () => _open(p, RecordSection.visits)),
          action(Icons.add_a_photo_rounded, 'Add\ndocument', () => _open(p, RecordSection.documents)),
          action(Icons.person_add_alt_1_rounded, 'Add\nperson',
              () => showAddPersonSheet(context, () => setState(() {}))),
          action(Icons.lock_person_rounded, 'Share\naccess', () => _open(p, RecordSection.access)),
        ],
      ),
    );
  }

  // ───────── records ─────────
  Widget _recordTile(Person p, MedicalRecord r) {
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(16),
      onTap: () => _open(p, RecordSection.history),
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

import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';
import 'access_section.dart';
import 'appointments_screen.dart';
import 'documents_section.dart';
import 'medical_history_screen.dart';
import 'add_record_sheet.dart';
import 'add_visit_sheet.dart';
import '../data/care_store.dart';

enum RecordSection { overview, history, visits, documents, access }

/// ONE person's record. The same screen serves:
///  • the caregiver (full edit)           -> readOnly: false
///  • the person themselves (view only)   -> readOnly: true, embedded: true
class PersonRecordScreen extends StatefulWidget {
  final Person person;
  final bool readOnly;
  final bool embedded; // true when shown inside a tab (no back button / own scaffold)
  final RecordSection initial;

  const PersonRecordScreen({
    super.key,
    required this.person,
    this.readOnly = false,
    this.embedded = false,
    this.initial = RecordSection.overview,
  });

  

  @override
  State<PersonRecordScreen> createState() => _PersonRecordScreenState();
}



class _PersonRecordScreenState extends State<PersonRecordScreen> {
  late RecordSection _section = widget.initial;

  static const _meta = <RecordSection, (String, IconData)>{
    RecordSection.overview: ('Overview', Icons.dashboard_rounded),
    RecordSection.history: ('History', Icons.history_edu_rounded),
    RecordSection.visits: ('Visits', Icons.local_hospital_rounded),
    RecordSection.documents: ('Documents & Scans', Icons.folder_copy_rounded),
    RecordSection.access: ('Access', Icons.lock_person_rounded),
  };

  Person get p => widget.person;

    @override
  void initState() {
    super.initState();
    visitsStore.addListener(_refresh);
    recordsStore.addListener(_refresh);
  }

  @override
  void dispose() {
    visitsStore.removeListener(_refresh);
    recordsStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        _chips(),
        const SizedBox(height: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(_section), child: _body()),
          ),
        ),
      ],
    );

    if (widget.embedded) return content;
    return Scaffold(body: AppBackground(child: SafeArea(child: content)));
  }

  Widget _header() {
    final members = (mockAccess[p.id] ?? []).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 24, 14),
      child: Row(
        children: [
          if (!widget.embedded)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.55)),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.maroon),
              ),
            )
          else
            const SizedBox(width: 4),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.maroon, AppColors.maroonDark]),
            ),
            child: Text(p.name[0], style: AppTheme.heading(24, color: AppColors.sand)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.readOnly ? 'My Record' : p.name, style: AppTheme.heading(24)),
                Text(
                  widget.readOnly
                      ? 'Everything about my care, in one place'
                      : '${p.subtitle.isEmpty ? '' : '${p.subtitle} · '}$members people have access',
                  style: AppTheme.body(12.5, color: AppColors.tan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: RecordSection.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = RecordSection.values[i];
          final selected = s == _section;
          final (label, icon) = _meta[s]!;
          return GestureDetector(
            onTap: () => setState(() => _section = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.maroon : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: selected ? AppColors.maroon : Colors.white.withOpacity(0.8)),
              ),
              child: Row(children: [
                Icon(icon, size: 17, color: selected ? AppColors.sand : AppColors.brown),
                const SizedBox(width: 7),
                Text(label,
                    style: AppTheme.body(13,
                        color: selected ? AppColors.sand : AppColors.brown,
                        weight: FontWeight.w700)),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _soon(String what) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$what — coming soon', style: AppTheme.body(14, color: AppColors.sand))),
      );

    Widget _addBar(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 14),
        child: PillButton(label: label, icon: Icons.add_rounded, onPressed: onTap),
      );

  Widget _body() {
    switch (_section) {
      case RecordSection.overview:
        return _overview();
      case RecordSection.history:
        return Column(children: [
if (!widget.readOnly)
  _addBar('ADD MEDICAL RECORD',
      () => showAddRecordSheet(context, p.id, () => setState(() {}))),          
Expanded(
  child: MedicalHistoryScreen(
    personId: p.id,
    showHeader: false,
    canEdit: !widget.readOnly,
    onChanged: () => setState(() {}),
  ),
),        ]);
      case RecordSection.visits:
        return Column(children: [
if (!widget.readOnly)
  _addBar('ADD HOSPITAL VISIT',
      () => showAddVisitSheet(context, p.id, () => setState(() {}))),          
Expanded(
  child: AppointmentsScreen(
    personId: p.id,
    showHeader: false,
    canEdit: !widget.readOnly,
  ),
),        ]);
      case RecordSection.documents:
        return DocumentsSection(personId: p.id, readOnly: widget.readOnly);
      case RecordSection.access:
        return AccessSection(person: p, readOnly: widget.readOnly);
    }
  }

  // ───────── overview ─────────
  Widget _overview() {
    final caregivers =
        (mockAccess[p.id] ?? []).where((m) => m.role == 'Caregiver').map((m) => m.name).toList();
    final history = mockRecords.where((r) => r.personId == p.id).length;
    final visits =
        mockAppointments.where((a) => a.personId == p.id && a.isUpcoming).length;
    final docs = mockDocuments.where((d) => d.personId == p.id).length;
    final scans = mockScans.where((s) => s.personId == p.id).length;

    return ListView(
      
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
      children: [
                if (!widget.readOnly && history + visits + docs + scans == 0) ...[
          _getStarted(),
          const SizedBox(height: 16),
        ],
        
        
        GlassCard(
          radius: 32,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              
              const Icon(Icons.volunteer_activism_rounded, color: AppColors.maroon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOOKED AFTER BY', style: AppTheme.label()),
                    Text(caregivers.isEmpty ? 'No caregiver yet' : caregivers.join(', '),
                        style: AppTheme.body(15, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _tile(Icons.history_edu_rounded, '$history', 'Medical history',
                  RecordSection.history)),
          const SizedBox(width: 14),
          Expanded(
              child: _tile(Icons.local_hospital_rounded, '$visits', 'Upcoming visits',
                  RecordSection.visits)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _tile(Icons.description_rounded, '$docs', 'Documents',
                  RecordSection.documents)),
          const SizedBox(width: 14),
          Expanded(
              child: _tile(Icons.biotech_rounded, '$scans', 'X-rays & scans',
                  RecordSection.documents,
                  dark: true)),
        ]),
        const SizedBox(height: 14),
        _tile(Icons.lock_person_rounded,
            '${(mockAccess[p.id] ?? []).length}', 'People with access', RecordSection.access,
            wide: true),
      ],
    );
  }

    Widget _getStarted() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.flag_rounded, color: AppColors.maroon),
              const SizedBox(width: 10),
              Text('Get started', style: AppTheme.heading(18)),
            ]),
            const SizedBox(height: 8),
            Text('This record is empty. Add the first thing:',
                style: AppTheme.body(14, color: AppColors.brown)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _startChip('Hospital visit', Icons.local_hospital_rounded, RecordSection.visits),
                _startChip('Medical record', Icons.history_edu_rounded, RecordSection.history),
                _startChip('Document or X-ray', Icons.add_a_photo_rounded, RecordSection.documents),
              ],
            ),
          ],
        ),
      );

  Widget _startChip(String label, IconData icon, RecordSection target) => GestureDetector(
        onTap: () => setState(() => _section = target),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: AppColors.sand),
            const SizedBox(width: 6),
            Text(label,
                style: AppTheme.body(13, color: AppColors.sand, weight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _tile(IconData icon, String value, String label, RecordSection target,
      {bool dark = false, bool wide = false}) {
    final fg = dark ? Colors.white : AppColors.maroon;
    final sub = dark ? AppColors.scanAccent : AppColors.tan;
    final inner = Row(
      children: [
        Icon(icon, size: 26, color: dark ? AppColors.scanAccent : AppColors.brown),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTheme.heading(26, color: fg)),
            Text(label, style: AppTheme.body(12.5, color: sub)),
          ],
        ),
      ],
    );

    if (dark) {
      return GestureDetector(
        onTap: () => setState(() => _section = target),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.scanDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.scanAccent.withOpacity(0.3)),
          ),
          child: inner,
        ),
      );
    }
    return SizedBox(
      width: wide ? double.infinity : null,
      child: GlassCard(
        radius: 28,
        padding: const EdgeInsets.all(18),
        onTap: () => setState(() => _section = target),
        child: inner,
      ),
    );
  }
}

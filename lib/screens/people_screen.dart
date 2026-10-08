import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../data/people_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_header.dart';
import '../widgets/pill_button.dart';
import 'person_record_screen.dart';
import '../data/care_store.dart';
/// Opens the "add person" form. [onAdded] (optional) runs after saving.
Future<void> showAddPersonSheet(BuildContext context, [VoidCallback? onAdded]) {
  return showAppSheet<void>(
    context,
    title: 'Add a person',
    child: _AddPersonForm(onAdded: onAdded),
  );
}

class _AddPersonForm extends StatefulWidget {
  final VoidCallback? onAdded;
  const _AddPersonForm({this.onAdded});

  @override
  State<_AddPersonForm> createState() => _AddPersonFormState();
}

class _AddPersonFormState extends State<_AddPersonForm> {
  final _name = TextEditingController();
  final _relation = TextEditingController();
  final _age = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _relation.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await peopleStore.add(
        name: name,
        relation: _relation.text.trim(),
        age: int.tryParse(_age.text.trim()),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onAdded?.call();
    } catch (e) {
      debugPrint('Adding person failed: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Each person gets their own record that you can share with others.',
            style: AppTheme.body(13.5, color: AppColors.tan)),
        const SizedBox(height: 18),
        AppTextField(label: 'Full name', icon: Icons.person_outline_rounded, controller: _name),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Relation (e.g. Mother)',
            icon: Icons.favorite_border_rounded,
            controller: _relation),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Age (optional)',
            icon: Icons.cake_outlined,
            controller: _age,
            keyboardType: TextInputType.number),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppTheme.body(13, color: Colors.red.shade700)),
        ],
        const SizedBox(height: 22),
        PillButton(
          label: _saving ? 'SAVING…' : 'ADD PERSON',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: _saving ? () {} : _save,
        ),
      ],
    );
  }
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([peopleStore, visitsStore]),
            builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'People in your care',
            subtitle: 'Every person has their own record',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PillButton(
              label: 'ADD PERSON',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: () => showAddPersonSheet(context),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
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
      return const EmptyState(
        icon: Icons.groups_rounded,
        title: 'No one added yet',
        message: 'Tap "ADD PERSON" above to create a record for someone you look after.',
      );
    }
    return RefreshIndicator(
      color: AppColors.maroon,
      onRefresh: peopleStore.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        itemCount: mockPeople.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _PersonCard(
          person: mockPeople[i],
          onBack: () => setState(() {}),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;
  final VoidCallback onBack;
  const _PersonCard({required this.person, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final upcoming = mockAppointments
        .where((a) => a.personId == person.id && a.isUpcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final docs = mockDocuments.where((d) => d.personId == person.id).length;
    final scans = mockScans.where((s) => s.personId == person.id).length;
    final shared = (mockAccess[person.id] ?? []).length;

    return GlassCard(
      radius: 36,
      onTap: () async {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => PersonRecordScreen(person: person)));
        onBack();
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.maroon, AppColors.maroonDark]),
            ),
            child: Text(person.name[0], style: AppTheme.heading(24, color: AppColors.sand)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: AppTheme.heading(20)),
                if (person.subtitle.isNotEmpty)
                  Text(person.subtitle, style: AppTheme.body(13, color: AppColors.tan)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                        Icons.event_rounded,
                        upcoming.isEmpty
                            ? 'No visit planned'
                            : 'Next ${DateFormat('MMM d').format(upcoming.first.dateTime)}'),
                    _chip(Icons.description_rounded, '$docs docs'),
                    _chip(Icons.biotech_rounded, '$scans scans', dark: true),
                    _chip(Icons.group_rounded, '$shared with access'),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.maroon),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, {bool dark = false}) {
    final fg = dark ? AppColors.scanDark : AppColors.brown;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? AppColors.scanAccent.withOpacity(0.35) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(text, style: AppTheme.body(11, color: fg, weight: FontWeight.w600)),
      ]),
    );
  }
}
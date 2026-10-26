import 'package:flutter/material.dart';
import '../data/care_store.dart';
import '../data/files_store.dart';
import '../data/mock_data.dart';
import '../data/people_store.dart';
import '../data/permissions.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/floating_nav.dart';
import 'contact_screen.dart';
import 'person_record_screen.dart';
import 'senior_dashboard_screen.dart';

/// The person's own app: Home · My Record · Contact (read-only).
class SeniorShell extends StatefulWidget {
  const SeniorShell({super.key});

  @override
  State<SeniorShell> createState() => _SeniorShellState();
}

class _SeniorShellState extends State<SeniorShell> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItem(Icons.folder_open_rounded, Icons.folder_rounded, 'My Record'),
    NavItem(Icons.support_agent_outlined, Icons.support_agent_rounded, 'Contact'),
  ];

  @override
  void initState() {
    super.initState();
    peopleStore.addListener(_refresh);
    visitsStore.addListener(_refresh);
    recordsStore.addListener(_refresh);
    filesStore.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await peopleStore.load(); // also attaches any invites sent to my email
      visitsStore.load();
      recordsStore.load();
      filesStore.load();
    });
  }

  @override
  void dispose() {
    peopleStore.removeListener(_refresh);
    visitsStore.removeListener(_refresh);
    recordsStore.removeListener(_refresh);
    filesStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // The record where my access role is "Self" (invited as "Themselves").
    final mine = mockPeople.where((p) => myAccessTo(p.id)?.role == 'Self').toList();
    final me = mine.isEmpty ? null : mine.first;

    const noRecord = EmptyState(
      icon: Icons.folder_shared_rounded,
      title: 'No record shared with you yet',
      message:
          'Ask your caregiver to invite you using this email address. Once they do, your visits, medicines and documents will show up here.',
    );

    final pages = <Widget>[
      me == null
          ? noRecord
          : SeniorDashboardScreen(person: me, onNavigate: (i) => setState(() => _index = i)),
      me == null ? noRecord : PersonRecordScreen(person: me, readOnly: true, embedded: true),
      const ContactScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar:
          FloatingNav(items: _items, index: _index, onTap: (i) => setState(() => _index = i)),
    );
  }
}
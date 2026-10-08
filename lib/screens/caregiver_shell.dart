import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/floating_nav.dart';
import 'appointments_screen.dart';
import 'contact_screen.dart';
import 'dashboard_screen.dart';
import 'people_screen.dart';
import '../data/people_store.dart';
import '../data/care_store.dart';

/// Caregiver app: Home · People · Visits · Contact
class CaregiverShell extends StatefulWidget {
  const CaregiverShell({super.key});

  @override
  State<CaregiverShell> createState() => _CaregiverShellState();
}

class _CaregiverShellState extends State<CaregiverShell> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItem(Icons.groups_outlined, Icons.groups_rounded, 'People'),
    NavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Visits'),
    NavItem(Icons.support_agent_outlined, Icons.support_agent_rounded, 'Contact'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => peopleStore.load());
        WidgetsBinding.instance.addPostFrameCallback((_) {
      peopleStore.load();
      visitsStore.load();
      recordsStore.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onNavigate: (i) => setState(() => _index = i)),
      const PeopleScreen(),
      const AppointmentsScreen(),
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

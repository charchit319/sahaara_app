import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'appointments_screen.dart';
import 'contact_screen.dart';
import 'dashboard_screen.dart';
import 'medical_history_screen.dart';

/// Main app: 4 tabs + floating pill-shaped bottom bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Visits'),
    (Icons.folder_open_rounded, Icons.folder_rounded, 'Records'),
    (Icons.support_agent_outlined, Icons.support_agent_rounded, 'Contact'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onNavigate: (i) => setState(() => _index = i)),
      const AppointmentsScreen(),
      const MedicalHistoryScreen(),
      const ContactScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          // IndexedStack keeps each tab's state (e.g. ticked medications).
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                  color: AppColors.maroon.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == _index;
              final item = _items[i];
              return Expanded(
                flex: selected ? 2 : 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.sand : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(selected ? item.$2 : item.$1,
                            size: 22,
                            color: selected ? AppColors.maroon : AppColors.sand),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(item.$3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.body(12.5,
                                    color: AppColors.maroon, weight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

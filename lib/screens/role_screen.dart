import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/glass_card.dart';
import 'caregiver_shell.dart';
import 'senior_shell.dart';
import '../config.dart'; 
import 'login_screen.dart';
import '../data/people_store.dart';

/// Prototype stand-in for "which kind of account is this?".
/// Later this comes from the user's profile after login.
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  void _go(BuildContext context, Widget shell) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => shell,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(size: 70),
                const SizedBox(height: 18),
                Text('How will you use\nSahaara?', style: AppTheme.heading(32)),
                const SizedBox(height: 8),
                Text('You can change this later.',
                    style: AppTheme.body(14, color: AppColors.tan)),
                const SizedBox(height: 28),
                _RoleCard(
                  icon: Icons.volunteer_activism_rounded,
                  title: "I'm a caregiver",
                  body: 'I look after one or more people — manage their visits, records and documents.',
                  onTap: () => _go(context, const CaregiverShell()),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  icon: Icons.elderly_rounded,
                  title: 'I want to see my own care',
                  body: 'View my visits, medication and records that my family or caregiver keeps for me.',
                  onTap: () => _go(context, const SeniorShell()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.body, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 36,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(color: AppColors.maroon, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.sand, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.heading(19)),
                const SizedBox(height: 4),
                Text(body, style: AppTheme.body(13.5, color: AppColors.tan)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.maroon),
          const SizedBox(height: 18),
Center(
  child: TextButton(
    onPressed: () async {
      peopleStore.clear();
      await supabase.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    },
    child: Text('Not you? Log out',
        style: AppTheme.body(13.5, color: AppColors.brown, weight: FontWeight.w600)),
  ),
),
        ],
      ),
    );
  }
}

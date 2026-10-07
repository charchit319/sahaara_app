import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';
import 'home_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext context) {
    // Prototype: no auth yet. Later -> Supabase/your API sign-in.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const HomeShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.maroon,
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Logo placeholder -> swap for Image.asset('assets/images/app_logo_no_bg.png')
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.maroon, AppColors.maroonDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.maroon.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded,
                        color: AppColors.sand, size: 44),
                  ),
                  const SizedBox(height: 20),
                  Text('SAHAARA',
                      style: AppTheme.heading(30).copyWith(letterSpacing: 6)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.maroon),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('Geriatric Care',
                        style: AppTheme.body(13, color: AppColors.maroon, weight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'The hands that raised us\ndeserve hands that care.',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(22, color: AppColors.brown)
                        .copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    radius: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back', style: AppTheme.heading(24)),
                        const SizedBox(height: 4),
                        Text('Sign in to continue caring',
                            style: AppTheme.body(14, color: AppColors.tan)),
                        const SizedBox(height: 24),
                        const AppTextField(
                            label: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        const AppTextField(
                            label: 'Password', icon: Icons.lock_outline_rounded, isPassword: true),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Forgot password?',
                                style: AppTheme.body(13, color: AppColors.brown)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        PillButton(label: 'LOGIN', onPressed: () => _enter(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New to Sahaara?', style: AppTheme.body(14, color: AppColors.tan)),
                      TextButton(
                        onPressed: () {},
                        child: Text('Join Sahaara',
                            style: AppTheme.body(14,
                                color: AppColors.maroon, weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

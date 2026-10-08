import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/ribbon.dart';
import 'onboarding_screen.dart';
import '../config.dart';
import 'role_screen.dart';

/// Initial load screen: logo animates in, the Dhaka ribbon "loads" across the
/// bottom, then we move on to onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));

  late final Animation<double> _logoFade =
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.22, curve: Curves.easeOut));
  late final Animation<double> _logoScale =
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack));
  late final Animation<double> _textFade =
      CurvedAnimation(parent: _c, curve: const Interval(0.28, 0.55, curve: Curves.easeOut));
  late final Animation<double> _progress =
      CurvedAnimation(parent: _c, curve: const Interval(0.08, 1.0, curve: Curves.easeInOutCubic));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(_next);
  }

  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) => supabase.auth.currentSession != null
    ? const RoleScreen()
    : const OnboardingScreen(),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.6, end: 1.0).animate(_logoScale),
                        child: Container(
                          width: 190,
                          height: 190,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.45),
                            border: Border.all(color: Colors.white.withOpacity(0.8)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.maroon.withOpacity(0.15),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: const AppLogo(size: 130),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                            .animate(_textFade),
                        child: Column(
                          children: [
                            Text('SAHAARA',
                                style: AppTheme.heading(32).copyWith(letterSpacing: 8)),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                'The hands that raised us deserve hands that care.',
                                textAlign: TextAlign.center,
                                style: AppTheme.heading(15, color: AppColors.brown).copyWith(
                                    fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _textFade,
              child: Text('Preparing your care space…',
                  style: AppTheme.body(12.5, color: AppColors.tan)),
            ),
            const SizedBox(height: 14),
            // Ribbon band that "loads" from left to right.
            SizedBox(
              height: 30,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(color: AppColors.maroon.withOpacity(0.08)),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => Align(
                      alignment: Alignment.centerLeft,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progress.value,
                          child: SizedBox(width: width, height: 30, child: const Ribbon(vertical: false)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

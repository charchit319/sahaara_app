import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/ribbon.dart';
import 'login_screen.dart';

class _Slide {
  final String title;
  final String body;
  final int kind; // 0 = photo, 1 = features, 2 = family
  const _Slide(this.title, this.body, this.kind);
}

const _slides = <_Slide>[
  _Slide(
    'Care that feels human',
    "Aging is inevitable. Navigating it alone shouldn't be. Sahaara helps families care for the people who raised them — with less worry and more time together.",
    0,
  ),
  _Slide(
    'Everything in one place',
    'Medication reminders, appointments and health records — neatly organised for every patient you look after.',
    1,
  ),
  _Slide(
    'Care, together',
    'Bring siblings and caregivers on board so everyone sees the same schedule, records and updates. Nobody is left guessing.',
    2,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const LoginScreen(),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
                if (!_isLast)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: GestureDetector(
                      onTap: _finish,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.maroon.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('Skip',
                            style: AppTheme.body(13, color: AppColors.sand, weight: FontWeight.w600)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // controls
          Padding(
            padding: EdgeInsets.fromLTRB(
                28, 8, 28, MediaQuery.of(context).padding.bottom + 22),
            child: Row(
              children: [
                Row(
                  children: List.generate(_slides.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: active ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? AppColors.maroon : AppColors.tan.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Material(
                  color: AppColors.maroon,
                  shape: const StadiumBorder(),
                  elevation: 6,
                  shadowColor: AppColors.maroon.withOpacity(0.5),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: _next,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_isLast ? 'Get Started' : 'Next',
                              style: AppTheme.body(15,
                                  color: AppColors.sand, weight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 18, color: AppColors.sand),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 11,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _background(),
                _foreground(context),
                const Positioned(left: 0, right: 0, bottom: 0, height: 24, child: Ribbon(vertical: false)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slide.title, style: AppTheme.heading(28)),
                const SizedBox(height: 12),
                Text(slide.body, style: AppTheme.body(15.5).copyWith(height: 1.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _background() {
    if (slide.kind == 0) {
      return Image.asset(
        'assets/images/landing_hero.png',
        fit: BoxFit.cover,
        alignment: const Alignment(0.4, -0.3),
        color: AppColors.sand.withOpacity(0.6),
        colorBlendMode: BlendMode.multiply,
        errorBuilder: (_, __, ___) => Container(color: AppColors.tan),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.maroon, AppColors.maroonDark],
        ),
      ),
    );
  }

  Widget _foreground(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    switch (slide.kind) {
      case 0:
        return Positioned(
          left: 24,
          top: top + 14,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cream.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const AppLogo(size: 56),
          ),
        );
      case 1:
        return Padding(
          padding: EdgeInsets.fromLTRB(28, top + 56, 28, 46),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _FeatureTile(Icons.medication_rounded, 'Medication reminders',
                      'Never miss a dose'),
                  SizedBox(height: 12),
                  _FeatureTile(Icons.calendar_month_rounded, 'Appointment tracking',
                      'Every visit, in one calendar'),
                  SizedBox(height: 12),
                  _FeatureTile(Icons.folder_rounded, 'Health records',
                      'Diagnoses & prescriptions together'),
                ],
              ),
            ),
          ),
        );
      default:
        return Padding(
          padding: EdgeInsets.fromLTRB(28, top + 56, 28, 46),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _AvatarRow(),
                  const SizedBox(height: 26),
                  const _FeatureTile(Icons.groups_rounded, 'Family collaboration',
                      'Everyone stays in the loop'),
                  const SizedBox(height: 12),
                  const _FeatureTile(Icons.share_rounded, 'Shared records',
                      'Invite siblings & caregivers'),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureTile(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: AppColors.sand, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.maroon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTheme.body(15.5, color: AppColors.sand, weight: FontWeight.w700)),
                Text(subtitle,
                    style: AppTheme.body(12.5, color: AppColors.sand.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow();

  @override
  Widget build(BuildContext context) {
    const colors = [AppColors.tan, AppColors.brown, AppColors.sand, AppColors.cream];
    return SizedBox(
      height: 72,
      width: 46.0 * 3 + 72,
      child: Stack(
        children: List.generate(4, (i) {
          return Positioned(
            left: i * 46.0,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.maroon, width: 4),
              ),
              child: Icon(Icons.person_rounded,
                  color: i < 2 ? AppColors.cream : AppColors.maroon, size: 34),
            ),
          );
        }),
      ),
    );
  }
}

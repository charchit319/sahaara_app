import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../widgets/pill_button.dart';
import 'role_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _loading = false;
  String? _message;
  bool _isError = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _show(String text, {bool error = true}) =>
      setState(() {
        _message = text;
        _isError = error;
      });

  void _goIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const RoleScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 6) {
      _show('Enter your email and a password of at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      if (_signUp) {
        await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': _name.text.trim()},
        );
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }
      if (!mounted) return;
      if (supabase.auth.currentSession == null) {
        _show('Check your inbox to confirm your email, then log in.', error: false);
        return;
      }
      _goIn();
    } on AuthException catch (e) {
      if (mounted) _show(e.message);
    } catch (_) {
      if (mounted) _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _show('Type your email first, then tap "Forgot password?".');
      return;
    }
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (mounted) _show('Password reset email sent.', error: false);
    } on AuthException catch (e) {
      if (mounted) _show(e.message);
    }
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
                  const AppLogo(size: 96),
                  const SizedBox(height: 14),
                  Text('SAHAARA', style: AppTheme.heading(30).copyWith(letterSpacing: 6)),
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
                  const SizedBox(height: 26),
                  Text(
                    'The hands that raised us\ndeserve hands that care.',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(21, color: AppColors.brown)
                        .copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    radius: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_signUp ? 'Create your account' : 'Welcome back',
                            style: AppTheme.heading(24)),
                        const SizedBox(height: 4),
                        Text(_signUp ? 'It only takes a minute' : 'Sign in to continue caring',
                            style: AppTheme.body(14, color: AppColors.tan)),
                        const SizedBox(height: 22),
                        if (_signUp) ...[
                          AppTextField(
                              label: 'Your name',
                              icon: Icons.person_outline_rounded,
                              controller: _name),
                          const SizedBox(height: 14),
                        ],
                        AppTextField(
                            label: 'Email',
                            icon: Icons.mail_outline_rounded,
                            controller: _email,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        AppTextField(
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            controller: _password,
                            isPassword: true),
                        if (!_signUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgot,
                              child: Text('Forgot password?',
                                  style: AppTheme.body(13, color: AppColors.brown)),
                            ),
                          )
                        else
                          const SizedBox(height: 10),
                        if (_message != null) ...[
                          Text(_message!,
                              style: AppTheme.body(13,
                                  color: _isError ? Colors.red.shade700 : AppColors.success)),
                          const SizedBox(height: 10),
                        ],
                        PillButton(
                          label: _loading
                              ? 'PLEASE WAIT…'
                              : (_signUp ? 'CREATE ACCOUNT' : 'LOGIN'),
                          onPressed: _loading ? () {} : _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_signUp ? 'Already have an account?' : 'New to Sahaara?',
                          style: AppTheme.body(14, color: AppColors.tan)),
                      TextButton(
                        onPressed: () => setState(() {
                          _signUp = !_signUp;
                          _message = null;
                        }),
                        child: Text(_signUp ? 'Log in' : 'Join Sahaara',
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
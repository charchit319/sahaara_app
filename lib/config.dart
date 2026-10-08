import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  // Passed in at run/build time with --dart-define (see below).
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}

/// Shortcut used everywhere: supabase.auth, supabase.from('visits'), ...
SupabaseClient get supabase => Supabase.instance.client;

/// First name for greetings: from sign-up, else the part of the email before "@".
String get userName {
  final user = supabase.auth.currentUser;
  final full = (user?.userMetadata?['full_name'] as String?)?.trim();
  if (full != null && full.isNotEmpty) return full.split(' ').first;
  final email = user?.email;
  if (email != null && email.contains('@')) return email.split('@').first;
  return 'there';
}
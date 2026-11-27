import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tracks optional Supabase initialization for self-hosted cloud sync.
///
/// By default (open-source local-first mode), Bookaind runs with zero cloud
/// dependencies. Users or contributors who deploy their own Supabase instance
/// can supply `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...`.
class SupabaseConfig {
  static const String envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static bool get hasCredentials =>
      envUrl.trim().isNotEmpty && envAnonKey.trim().isNotEmpty;

  static Future<void> initializeIfConfigured() async {
    if (!hasCredentials) {
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: envUrl.trim(),
        anonKey: envAnonKey.trim(),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Supabase initialization skipped (running local-first): $e');
      _isInitialized = false;
    }
  }

  static SupabaseClient? get clientOrNull =>
      _isInitialized ? Supabase.instance.client : null;
}

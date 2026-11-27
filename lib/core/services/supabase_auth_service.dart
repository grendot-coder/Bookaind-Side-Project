import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseAuthService {
  static SupabaseClient? get _client => SupabaseConfig.clientOrNull;

  static bool get isCloudAvailable => SupabaseConfig.isInitialized;

  /// Current authenticated user (null if guest or running local-first)
  static User? get currentUser => _client?.auth.currentUser;

  /// Auth state stream when Supabase is configured, otherwise empty stream
  static Stream<AuthState> get onAuthStateChange =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Sign Up with Email & Password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Cloud sync is not configured. Bookaind is running in local-first mode.',
      );
    }
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Sign In with Email & Password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Cloud sync is not configured. Bookaind is running in local-first mode.',
      );
    }
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign Out
  static Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}

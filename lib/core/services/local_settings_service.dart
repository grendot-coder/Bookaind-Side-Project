import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AiProviderType {
  groq,
  gemini;

  String get displayName {
    switch (this) {
      case AiProviderType.groq:
        return 'Groq (LLaMA 3.3 70B)';
      case AiProviderType.gemini:
        return 'Google Gemini (2.5 Flash)';
    }
  }

  String get shortLabel {
    switch (this) {
      case AiProviderType.groq:
        return 'Groq';
      case AiProviderType.gemini:
        return 'Gemini';
    }
  }

  String get keyConsoleUrl {
    switch (this) {
      case AiProviderType.groq:
        return 'https://console.groq.com/keys';
      case AiProviderType.gemini:
        return 'https://aistudio.google.com/app/apikey';
    }
  }

  String get keyHint {
    switch (this) {
      case AiProviderType.groq:
        return 'gsk_...';
      case AiProviderType.gemini:
        return 'AIza...';
    }
  }
}

@immutable
class AiSettingsState {
  final AiProviderType provider;
  final String apiKey;
  final bool isLoaded;

  const AiSettingsState({
    this.provider = AiProviderType.groq,
    this.apiKey = '',
    this.isLoaded = false,
  });

  bool get hasApiKey => apiKey.trim().isNotEmpty;

  AiSettingsState copyWith({
    AiProviderType? provider,
    String? apiKey,
    bool? isLoaded,
  }) {
    return AiSettingsState(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class LocalStorageKeys {
  static const String aiProvider = 'bookaind_ai_provider';
  static const String byokApiKey = 'bookaind_byok_api_key';
  static const String bookmarks = 'bookaind_bookmarks_v1';
  static const String savedItineraries = 'bookaind_saved_itineraries_v1';
  static const String culturalPassions = 'bookaind_cultural_passions_v1';
  static const String language = 'bookaind_language_v1';
}

/// Manages encrypted API key storage and lightweight local preferences.
class LocalSettingsService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String? _cachedApiKey;
  static AiProviderType _cachedProvider = AiProviderType.groq;

  static Future<void> warmUpCache(SharedPreferences prefs) async {
    final providerName = prefs.getString(LocalStorageKeys.aiProvider);
    _cachedProvider = AiProviderType.values.firstWhere(
      (p) => p.name == providerName,
      orElse: () => AiProviderType.groq,
    );

    try {
      _cachedApiKey = await _secureStorage.read(key: LocalStorageKeys.byokApiKey);
    } catch (e) {
      debugPrint('Secure storage read fallback: $e');
      _cachedApiKey = null;
    }
  }

  static AiProviderType get cachedProvider => _cachedProvider;
  static String get cachedApiKey => (_cachedApiKey ?? '').trim();
  static bool get hasCachedApiKey => cachedApiKey.isNotEmpty;

  static Future<void> saveAiSettings(
    SharedPreferences prefs, {
    required AiProviderType provider,
    required String apiKey,
  }) async {
    final trimmedKey = apiKey.trim();
    _cachedProvider = provider;
    _cachedApiKey = trimmedKey;

    await prefs.setString(LocalStorageKeys.aiProvider, provider.name);
    try {
      if (trimmedKey.isEmpty) {
        await _secureStorage.delete(key: LocalStorageKeys.byokApiKey);
      } else {
        await _secureStorage.write(
          key: LocalStorageKeys.byokApiKey,
          value: trimmedKey,
        );
      }
    } catch (e) {
      debugPrint('Secure storage write warning: $e');
    }
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

class AiSettingsNotifier extends StateNotifier<AiSettingsState> {
  final SharedPreferences _prefs;

  AiSettingsNotifier(this._prefs)
      : super(
          AiSettingsState(
            provider: LocalSettingsService.cachedProvider,
            apiKey: LocalSettingsService.cachedApiKey,
            isLoaded: true,
          ),
        );

  Future<void> updateSettings({
    required AiProviderType provider,
    required String apiKey,
  }) async {
    await LocalSettingsService.saveAiSettings(
      _prefs,
      provider: provider,
      apiKey: apiKey,
    );
    state = state.copyWith(
      provider: provider,
      apiKey: apiKey.trim(),
      isLoaded: true,
    );
  }

  Future<void> clearApiKey() async {
    await updateSettings(provider: state.provider, apiKey: '');
  }
}

final aiSettingsProvider =
    StateNotifierProvider<AiSettingsNotifier, AiSettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AiSettingsNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs)
      : super(_prefs.getString(LocalStorageKeys.language) ?? 'English');

  Future<void> setLanguage(String language) async {
    state = language;
    await _prefs.setString(LocalStorageKeys.language, language);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_settings_service.dart';
import 'supabase_config.dart';

class AiGatewayException implements Exception {
  final String message;
  final bool isMissingKey;
  final bool isAuthError;
  final bool isRateLimit;

  const AiGatewayException(
    this.message, {
    this.isMissingKey = false,
    this.isAuthError = false,
    this.isRateLimit = false,
  });

  @override
  String toString() => message;
}

class AiConnectionTestResult {
  final bool isSuccess;
  final String message;
  final String? resolvedModel;

  const AiConnectionTestResult({
    required this.isSuccess,
    required this.message,
    this.resolvedModel,
  });
}

/// Routes AI requests through the user's on-device BYOK API key (Groq or Gemini),
/// falling back to an optional self-hosted Supabase Edge Function if configured.
class AiGatewayService {
  static const Duration _timeout = Duration(seconds: 35);

  static String? _cachedGroqModel;
  static String? _cachedGeminiModel;

  static const List<String> _groqPreferredModels = [
    'llama-3.3-70b-versatile',
    'meta-llama/llama-4-scout-17b-16e-instruct',
    'openai/gpt-oss-120b',
    'llama-3.1-8b-instant',
    'qwen/qwen3-32b',
  ];

  static const List<String> _geminiPreferredModels = [
    'gemini-2.5-flash',
    'gemini-3.8-flash',
    'gemini-2.0-flash',
  ];

  static void clearModelCache() {
    _cachedGroqModel = null;
    _cachedGeminiModel = null;
  }

  static Future<String> generateText({
    required String userPrompt,
    List<Map<String, String>> conversationHistory = const [],
    String? systemPrompt,
  }) async {
    final apiKey = LocalSettingsService.cachedApiKey;
    final provider = LocalSettingsService.cachedProvider;

    if (apiKey.isNotEmpty) {
      switch (provider) {
        case AiProviderType.groq:
          final result = await _callGroqWithDiscovery(
            apiKey: apiKey,
            userPrompt: userPrompt,
            conversationHistory: conversationHistory,
            systemPrompt: systemPrompt,
          );
          return result.$1;
        case AiProviderType.gemini:
          final result = await _callGeminiWithDiscovery(
            apiKey: apiKey,
            userPrompt: userPrompt,
            conversationHistory: conversationHistory,
            systemPrompt: systemPrompt,
          );
          return result.$1;
      }
    }

    final supabaseClient = SupabaseConfig.clientOrNull;
    if (supabaseClient != null) {
      final response = await supabaseClient.functions.invoke(
        'smooth-processor',
        body: {
          'userPrompt': userPrompt,
          'conversationHistory': conversationHistory,
        },
      );
      final data = response.data;
      if (data is Map && data['answer'] != null) {
        return data['answer'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
      if (data is Map && data['error'] != null) {
        throw AiGatewayException(data['error'].toString());
      }
      throw const AiGatewayException('Empty response from cloud proxy.');
    }

    throw const AiGatewayException(
      'No AI API key configured. Add a free Groq or Gemini key in Settings.',
      isMissingKey: true,
    );
  }

  /// Tests a candidate API key before saving it and auto-discovers an accessible model.
  static Future<AiConnectionTestResult> testConnection({
    required AiProviderType provider,
    required String apiKey,
  }) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      return const AiConnectionTestResult(
        isSuccess: false,
        message: 'Please paste an API key first.',
      );
    }

    clearModelCache();

    try {
      switch (provider) {
        case AiProviderType.groq:
          final (_, model) = await _callGroqWithDiscovery(
            apiKey: trimmed,
            userPrompt: 'Reply with the single word: OK',
          );
          return AiConnectionTestResult(
            isSuccess: true,
            resolvedModel: model,
            message: 'Connected to Groq ($model).',
          );
        case AiProviderType.gemini:
          final (_, model) = await _callGeminiWithDiscovery(
            apiKey: trimmed,
            userPrompt: 'Reply with the single word: OK',
          );
          return AiConnectionTestResult(
            isSuccess: true,
            resolvedModel: model,
            message: 'Connected to Gemini ($model).',
          );
      }
    } on AiGatewayException catch (e) {
      return AiConnectionTestResult(isSuccess: false, message: e.message);
    } catch (e) {
      return AiConnectionTestResult(
        isSuccess: false,
        message: 'Connection failed: $e',
      );
    }
  }

  static Future<(String, String)> _callGroqWithDiscovery({
    required String apiKey,
    required String userPrompt,
    List<Map<String, String>> conversationHistory = const [],
    String? systemPrompt,
  }) async {
    final initialModel = _cachedGroqModel ?? _groqPreferredModels.first;
    try {
      final content = await _postGroq(
        apiKey: apiKey,
        model: initialModel,
        userPrompt: userPrompt,
        conversationHistory: conversationHistory,
        systemPrompt: systemPrompt,
      );
      _cachedGroqModel = initialModel;
      return (content, initialModel);
    } on _ModelNotFoundException {
      final available = await _discoverGroqChatModels(apiKey);
      for (final model in available) {
        if (model == initialModel) continue;
        try {
          final content = await _postGroq(
            apiKey: apiKey,
            model: model,
            userPrompt: userPrompt,
            conversationHistory: conversationHistory,
            systemPrompt: systemPrompt,
          );
          _cachedGroqModel = model;
          return (content, model);
        } on _ModelNotFoundException {
          continue;
        }
      }
      throw const AiGatewayException(
        'No active chat models were accessible with this Groq API key. '
        'Check Allowed Models in your Groq Console project settings.',
      );
    }
  }

  static Future<List<String>> _discoverGroqChatModels(String apiKey) async {
    final response = await http
        .get(
          Uri.parse('https://api.groq.com/openai/v1/models'),
          headers: {'Authorization': 'Bearer $apiKey'},
        )
        .timeout(_timeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AiGatewayException(
        'Invalid Groq API key. Please verify your key in Settings.',
        isAuthError: true,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiGatewayException(
        'Could not list Groq models (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>? ?? [];
    final allIds = data
        .whereType<Map<String, dynamic>>()
        .map((m) => m['id']?.toString() ?? '')
        .where((id) {
          final lower = id.toLowerCase();
          return id.isNotEmpty &&
              !lower.contains('whisper') &&
              !lower.contains('tts') &&
              !lower.contains('orpheus') &&
              !lower.contains('guard') &&
              !lower.contains('safeguard');
        })
        .toList();

    final ordered = <String>[
      for (final preferred in _groqPreferredModels)
        if (allIds.contains(preferred)) preferred,
      for (final id in allIds)
        if (!_groqPreferredModels.contains(id)) id,
    ];
    return ordered;
  }

  static Future<String> _postGroq({
    required String apiKey,
    required String model,
    required String userPrompt,
    List<Map<String, String>> conversationHistory = const [],
    String? systemPrompt,
  }) async {
    final messages = <Map<String, String>>[
      if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
        {'role': 'system', 'content': systemPrompt.trim()},
      ...conversationHistory.map(
        (m) => {
          'role': m['role'] ?? 'user',
          'content': m['content'] ?? '',
        },
      ),
      {'role': 'user', 'content': userPrompt},
    ];

    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.6,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AiGatewayException(
        'Invalid Groq API key. Please verify your key in Settings.',
        isAuthError: true,
      );
    }
    if (response.statusCode == 429) {
      throw const AiGatewayException(
        'Groq rate limit reached. Please wait a moment and try again.',
        isRateLimit: true,
      );
    }
    if (response.statusCode == 404 ||
        (response.statusCode == 400 &&
            response.body.contains('model_not_found'))) {
      throw const _ModelNotFoundException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiGatewayException(
        'Groq API error (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>? ?? [];
    if (choices.isEmpty) {
      throw const AiGatewayException('Groq returned an empty response.');
    }
    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>?;
    final content = message?['content']?.toString() ?? '';
    if (content.trim().isEmpty) {
      throw const AiGatewayException('Groq returned empty message content.');
    }
    return content;
  }

  static Future<(String, String)> _callGeminiWithDiscovery({
    required String apiKey,
    required String userPrompt,
    List<Map<String, String>> conversationHistory = const [],
    String? systemPrompt,
  }) async {
    final initialModel = _cachedGeminiModel ?? _geminiPreferredModels.first;
    try {
      final content = await _postGemini(
        apiKey: apiKey,
        model: initialModel,
        userPrompt: userPrompt,
        conversationHistory: conversationHistory,
        systemPrompt: systemPrompt,
      );
      _cachedGeminiModel = initialModel;
      return (content, initialModel);
    } on _ModelNotFoundException {
      final available = await _discoverGeminiFlashModels(apiKey);
      for (final model in available) {
        if (model == initialModel) continue;
        try {
          final content = await _postGemini(
            apiKey: apiKey,
            model: model,
            userPrompt: userPrompt,
            conversationHistory: conversationHistory,
            systemPrompt: systemPrompt,
          );
          _cachedGeminiModel = model;
          return (content, model);
        } on _ModelNotFoundException {
          continue;
        }
      }
      throw const AiGatewayException(
        'No active Gemini Flash models were accessible with this API key.',
      );
    }
  }

  static Future<List<String>> _discoverGeminiFlashModels(String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=${Uri.encodeComponent(apiKey)}',
    );
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      throw const AiGatewayException(
        'Invalid Gemini API key. Please verify your key in Settings.',
        isAuthError: true,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiGatewayException(
        'Could not list Gemini models (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final models = decoded['models'] as List<dynamic>? ?? [];
    final allIds = models
        .whereType<Map<String, dynamic>>()
        .where((m) {
          final methods = (m['supportedGenerationMethods'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          return methods.contains('generateContent');
        })
        .map((m) => (m['name']?.toString() ?? '').replaceFirst('models/', ''))
        .where((name) => name.contains('flash'))
        .toList();

    final ordered = <String>[
      for (final preferred in _geminiPreferredModels)
        if (allIds.contains(preferred)) preferred,
      for (final id in allIds)
        if (!_geminiPreferredModels.contains(id)) id,
    ];
    return ordered;
  }

  static Future<String> _postGemini({
    required String apiKey,
    required String model,
    required String userPrompt,
    List<Map<String, String>> conversationHistory = const [],
    String? systemPrompt,
  }) async {
    final contents = <Map<String, dynamic>>[
      ...conversationHistory.map((m) {
        final role = m['role'] == 'assistant' ? 'model' : 'user';
        return {
          'role': role,
          'parts': [
            {'text': m['content'] ?? ''},
          ],
        };
      }),
      {
        'role': 'user',
        'parts': [
          {'text': userPrompt},
        ],
      },
    ];

    final payload = <String, dynamic>{
      'contents': contents,
      if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt.trim()},
          ],
        },
      'generationConfig': {
        'temperature': 0.6,
      },
    };

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/${Uri.encodeComponent(model)}:generateContent?key=${Uri.encodeComponent(apiKey)}',
    );

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    if (response.statusCode == 404) {
      throw const _ModelNotFoundException();
    }
    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      throw const AiGatewayException(
        'Invalid Gemini API key. Please verify your key in Settings.',
        isAuthError: true,
      );
    }
    if (response.statusCode == 429) {
      throw const AiGatewayException(
        'Gemini rate limit reached. Please wait a moment and try again.',
        isRateLimit: true,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiGatewayException(
        'Gemini API error (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>? ?? [];
    if (candidates.isEmpty) {
      throw const AiGatewayException('Gemini returned no candidates.');
    }
    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>? ?? [];
    if (parts.isEmpty) {
      throw const AiGatewayException('Gemini returned empty parts.');
    }
    final text = (parts.first as Map<String, dynamic>)['text']?.toString() ?? '';
    if (text.trim().isEmpty) {
      throw const AiGatewayException('Gemini returned empty text.');
    }
    return text;
  }
}

class _ModelNotFoundException implements Exception {
  const _ModelNotFoundException();
}

import 'package:supabase_flutter/supabase_flutter.dart';

class GroqCulturalService {
  /// Sends the prompt to the Supabase Edge Function and returns the answer text
  static Future<String> generateCulturalAnswer({
    required String userPrompt,
    required List<Map<String, String>> conversationHistory,
  }) async {
    final cleanPrompt = userPrompt.trim();
    if (cleanPrompt.isEmpty) {
      return 'Please ask a question about Indonesian culture, traditions, or travel.';
    }
    if (cleanPrompt.length > 600) {
      return 'Your query is quite long. Please keep questions within 600 characters for the best cultural answers.';
    }

    try {
      // Calls your Supabase Edge Function securely
      final response = await Supabase.instance.client.functions.invoke(
        'smooth-processor',
        body: {
          'userPrompt': cleanPrompt,
          'conversationHistory': conversationHistory,
        },
      );

      final data = response.data;
      if (data != null && data['answer'] != null) {
        return (data['answer'] as String).replaceAll('*', '').trim();
      } else if (data != null && data['error'] != null) {
        return 'Assistant error: ${data['error']}';
      } else {
        return 'Unable to retrieve cultural guide response. Please try again.';
      }
    } on FunctionException catch (e) {
      return 'Edge Function error (${e.status}): ${e.details ?? e.reasonPhrase ?? e.toString()}';
    } catch (e) {
      return 'Network error connecting to cultural guide: $e';
    }
  }
}

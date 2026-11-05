import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_secrets.dart';

class GroqCulturalService {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _apiKey = AppSecrets.groqApiKey;

  static const String _model = 'qwen/qwen3.8-27b';

  static const String _systemPrompt = '''
You are the Nusantara Cultural Guide for the mobile application "Bookaind" with the slogan "Just Move It".
Your mission is to help Indonesian and international visitors discover the cultural diversity, living traditions, favorite food feedback from the local, royal kingdoms, and travel destinations of Java, Indonesia.

Guidelines:
1. Tone: Welcoming, warm, culturally respectful, and adventurous (use occasional authentic greetings like "Sugeng Rawuh" or "Sampurasun").
2. Expertise: Javanese, Sundanese, and Betawi traditions, Candi architecture (Borobudur, Prambanan), Batik philosophies (Parang, Kawung), traditional culinary (Gudeg, Rawon), Wayang, Gamelan, and sacred etiquette.
3. Keep answers concise, engaging, and beautifully formatted with bullet points where appropriate.
4. If a question is unrelated to Indonesia or travel culture, gently guide the conversation back to discovering Nusantara.
5. Use less ** and just adequate emoji.
6. If the user said something in their languange, try to asnwer with the same languange if possible.
''';

  /// Sends the prompt to Groq and returns the streaming response text
  static Future<String> generateCulturalAnswer({
    required String userPrompt,
    required List<Map<String, String>> conversationHistory,
  }) async {
    // Fallback if the user hasn't pasted the key yet
    if (_apiKey == 'PASTE_YOUR_GROQ_API_KEY_HERE' || _apiKey.isEmpty) {
      return '⚠️ Please paste your Groq API key in `lib/core/services/groq_cultural_service.dart` to enable real-time Llama 3.3 cultural intelligence!';
    }

    try {
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': userPrompt},
      ];

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.6,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['choices'][0]['message']['content'] as String;
        return answer.trim();
      } else {
        final errorData = jsonDecode(response.body);
        return 'Groq Error (${response.statusCode}): ${errorData['error']?['message'] ?? 'Unable to connect to Groq'}';
      }
    } catch (e) {
      return 'Network error connecting to Groq: $e';
    }
  }
}

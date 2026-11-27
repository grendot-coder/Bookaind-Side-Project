import 'dart:convert';
import '../../features/discovery/models/itinerary_model.dart';
import 'ai_gateway_service.dart';

class ItineraryGenerationResult {
  final ItineraryPlan plan;
  final bool usedAi;
  final String? fallbackNotice;

  const ItineraryGenerationResult({
    required this.plan,
    required this.usedAi,
    this.fallbackNotice,
  });
}

class ItineraryService {
  /// Generates an itinerary via the user's BYOK AI key (or optional self-hosted
  /// proxy), returning a curated offline fallback with clear context if AI is unavailable.
  static Future<ItineraryGenerationResult> generateCulturalItineraryWithStatus(
    ItineraryRequest request,
  ) async {
    final prompt = '''
You are the master cultural trip architect for the mobile app "Bookaind" (Nusantara Cultural Heritage).
Create a realistic, highly authentic, and culturally rich ${request.durationDays}-day travel itinerary for: ${request.region}.
Travel Style: ${request.travelStyle}.
Budget/Explorer Level: ${request.budgetLevel}.
${request.notes.isNotEmpty ? 'User Notes: ${request.notes}' : ''}

CRITICAL RULES:
1. Focus on living heritage, ancient temples/monuments, royal keraton, traditional crafts (batik/weaving/wayang), and authentic local food stalls/warungs.
2. Structure the response strictly as valid JSON with NO conversational pleasantries, NO explanation outside the JSON.
3. Every day must contain exactly 3 slots: Morning, Afternoon, and Evening.
4. Include authentic cultural tips (modesty rules, sacred tree etiquette, greetings) and specific local culinary dish recommendations.

JSON Schema to strictly follow:
{
  "title": "${request.durationDays}-Day Heritage Odyssey in ${request.region}",
  "summary": "2-3 engaging sentences introducing this cultural journey.",
  "region": "${request.region}",
  "durationDays": ${request.durationDays},
  "days": [
    {
      "dayNumber": 1,
      "theme": "Theme title for this day",
      "activities": [
        {
          "timeSlot": "Morning (08:00 - 11:30)",
          "title": "Specific Site Visit",
          "description": "Engaging 2-sentence description of what to experience and observe.",
          "locationName": "Precise name of the place",
          "culturalTip": "Important cultural etiquette or historical fact.",
          "culinarySpot": "Authentic dish or nearby traditional warung recommendation"
        },
        {
          "timeSlot": "Afternoon (13:00 - 16:30)",
          "title": "Afternoon Heritage Experience",
          "description": "Engaging description.",
          "locationName": "Precise name of the place",
          "culturalTip": "Cultural etiquette.",
          "culinarySpot": "Dish recommendation"
        },
        {
          "timeSlot": "Evening (18:30 - 21:00)",
          "title": "Evening Tradition or Performance",
          "description": "Engaging description.",
          "locationName": "Precise name of the place",
          "culturalTip": "Evening atmosphere advice.",
          "culinarySpot": "Night market or legendary dinner stall"
        }
      ]
    }
  ],
  "packingAndEtiquetteTips": [
    "Tip 1 regarding dress code or footwear",
    "Tip 2 regarding cash/etiquette",
    "Tip 3 regarding best photo time or customs"
  ]
}
''';

    try {
      final answerText = await AiGatewayService.generateText(
        userPrompt: prompt,
      );

      String cleanJson = answerText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final parsedMap = jsonDecode(cleanJson) as Map<String, dynamic>;
      return ItineraryGenerationResult(
        plan: ItineraryPlan.fromMap(parsedMap),
        usedAi: true,
      );
    } on AiGatewayException catch (e) {
      return ItineraryGenerationResult(
        plan: ItineraryPlan.createCuratedFallback(request),
        usedAi: false,
        fallbackNotice: e.isMissingKey
            ? 'Showing curated offline route. Add a free Groq or Gemini key in Profile Settings for live AI planning.'
            : '${e.message} Showing curated route instead.',
      );
    } catch (_) {
      return ItineraryGenerationResult(
        plan: ItineraryPlan.createCuratedFallback(request),
        usedAi: false,
        fallbackNotice:
            'Unable to reach AI provider. Showing curated offline heritage route.',
      );
    }
  }

  static Future<ItineraryPlan> generateCulturalItinerary(
    ItineraryRequest request,
  ) async {
    final result = await generateCulturalItineraryWithStatus(request);
    return result.plan;
  }
}

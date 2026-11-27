import 'dart:convert';

/// Represents user criteria for generating an itinerary
class ItineraryRequest {
  final String region;
  final int durationDays;
  final String travelStyle;
  final String budgetLevel;
  final String notes;

  const ItineraryRequest({
    required this.region,
    required this.durationDays,
    required this.travelStyle,
    this.budgetLevel = 'Standard Explorer',
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'region': region,
    'durationDays': durationDays,
    'travelStyle': travelStyle,
    'budgetLevel': budgetLevel,
    'notes': notes,
  };
}

/// A specific activity slot (Morning, Afternoon, Evening)
class ItineraryActivity {
  final String timeSlot; // e.g., 'Morning (08:00 - 11:30)'
  final String title; // e.g., 'Sunrise at Candi Borobudur'
  final String description; // Brief narrative guide
  final String locationName; // Specific spot name
  final String? culturalTip; // Etiquette or custom
  final String? culinarySpot; // Authentic warung or dish

  const ItineraryActivity({
    required this.timeSlot,
    required this.title,
    required this.description,
    required this.locationName,
    this.culturalTip,
    this.culinarySpot,
  });

  factory ItineraryActivity.fromMap(Map<String, dynamic> map) {
    return ItineraryActivity(
      timeSlot: map['timeSlot']?.toString() ?? 'Morning',
      title: map['title']?.toString() ?? 'Cultural Discovery',
      description: map['description']?.toString() ?? '',
      locationName: map['locationName']?.toString() ?? '',
      culturalTip: map['culturalTip']?.toString(),
      culinarySpot: map['culinarySpot']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'timeSlot': timeSlot,
    'title': title,
    'description': description,
    'locationName': locationName,
    'culturalTip': culturalTip,
    'culinarySpot': culinarySpot,
  };
}

/// A single day of an itinerary
class ItineraryDay {
  final int dayNumber;
  final String theme; // e.g., 'Kingdoms & Royal Traditions'
  final List<ItineraryActivity> activities;

  const ItineraryDay({
    required this.dayNumber,
    required this.theme,
    required this.activities,
  });

  factory ItineraryDay.fromMap(Map<String, dynamic> map) {
    final rawActivities = map['activities'] as List<dynamic>? ?? [];
    return ItineraryDay(
      dayNumber: (map['dayNumber'] is int)
          ? map['dayNumber'] as int
          : int.tryParse(map['dayNumber']?.toString() ?? '1') ?? 1,
      theme: map['theme']?.toString() ?? 'Nusantara Exploration',
      activities: rawActivities
          .whereType<Map<String, dynamic>>()
          .map((a) => ItineraryActivity.fromMap(a))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'dayNumber': dayNumber,
    'theme': theme,
    'activities': activities.map((a) => a.toMap()).toList(),
  };
}

/// Complete generated itinerary plan
class ItineraryPlan {
  final String title;
  final String summary;
  final String region;
  final int durationDays;
  final List<ItineraryDay> days;
  final List<String> packingAndEtiquetteTips;
  final DateTime createdAt;

  ItineraryPlan({
    required this.title,
    required this.summary,
    required this.region,
    required this.durationDays,
    required this.days,
    required this.packingAndEtiquetteTips,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ItineraryPlan.fromMap(Map<String, dynamic> map) {
    final rawDays = map['days'] as List<dynamic>? ?? [];
    final rawTips = map['packingAndEtiquetteTips'] as List<dynamic>? ?? [];
    final parsedDate = map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'].toString())
        : null;

    return ItineraryPlan(
      title: map['title']?.toString() ?? 'Nusantara Cultural Journey',
      summary: map['summary']?.toString() ?? 'A curated exploration of heritage.',
      region: map['region']?.toString() ?? 'Indonesia',
      durationDays: (map['durationDays'] is int)
          ? map['durationDays'] as int
          : int.tryParse(map['durationDays']?.toString() ?? '1') ?? 1,
      days: rawDays
          .whereType<Map<String, dynamic>>()
          .map((d) => ItineraryDay.fromMap(d))
          .toList(),
      packingAndEtiquetteTips: rawTips.map((t) => t.toString()).toList(),
      createdAt: parsedDate,
    );
  }

  String get storageKey => '${region.trim().toLowerCase()}_${durationDays}_${title.trim().toLowerCase()}';

  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
    'title': title,
    'summary': summary,
    'region': region,
    'durationDays': durationDays,
    'days': days.map((d) => d.toMap()).toList(),
    'packingAndEtiquetteTips': packingAndEtiquetteTips,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Fallback curated itinerary in case AI or Edge Function is unreachable
  static ItineraryPlan createCuratedFallback(ItineraryRequest req) {
    return ItineraryPlan(
      title: '${req.durationDays}-Day Heritage Odyssey in ${req.region}',
      summary:
          'Experience the living soul of ${req.region}. Designed around authentic heritage landmarks, royal crafts, and legendary local warungs.',
      region: req.region,
      durationDays: req.durationDays,
      days: List.generate(req.durationDays, (index) {
        final dayNum = index + 1;
        return ItineraryDay(
          dayNumber: dayNum,
          theme: dayNum == 1
              ? 'Ancient Temples & Sacred Horizons'
              : dayNum == 2
                  ? 'Royal Courts, Batik & Heritage Markets'
                  : 'Living Traditions & Village Crafts',
          activities: [
            ItineraryActivity(
              timeSlot: 'Morning (08:00 - 11:30)',
              title: dayNum == 1
                  ? 'Exploration of Ancient Sanctuaries'
                  : 'Royal Heritage Walking Tour',
              description:
                  'Arrive early while the morning mist still lingers over the stone carvings and temple gardens.',
              locationName: req.region,
              culturalTip: 'Wear respectful attire covering knees and shoulders.',
              culinarySpot: 'Traditional morning market delicacies (Jajan Pasar)',
            ),
            ItineraryActivity(
              timeSlot: 'Afternoon (13:00 - 16:30)',
              title: 'Master Crafts & Living Artistry',
              description:
                  'Witness hereditary artisans carving intricate motifs and practicing traditional weaving.',
              locationName: '${req.region} Artisan Quarter',
              culturalTip: 'Ask permission before photographing artisans at work.',
              culinarySpot: 'Authentic local heritage restaurant',
            ),
            ItineraryActivity(
              timeSlot: 'Evening (18:30 - 21:00)',
              title: 'Twilight Classical Performance & Culinary Night',
              description:
                  'Conclude the day with traditional musical accompaniments and comforting heritage recipes.',
              locationName: 'Heritage Square',
              culinarySpot: 'Signature slow-cooked regional specialty',
            ),
          ],
        );
      }),
      packingAndEtiquetteTips: [
        'Carry a light cotton scarf or sarong for temple visits.',
        'Always use your right hand when receiving gifts or pointing respectfully.',
        'Keep small cash denominations ready for entrance donations and traditional markets.',
      ],
    );
  }
}

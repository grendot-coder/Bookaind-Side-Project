import 'package:flutter/foundation.dart';

/// Province cultural profile
@immutable
class Province {
  final String id;
  final String name;
  final String localName;
  final String capital;
  final String tagline;
  final String heroImageUrl;
  final double latitude;
  final double longitude;

  const Province({
    required this.id,
    required this.name,
    required this.localName,
    required this.capital,
    required this.tagline,
    required this.heroImageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      id: map['id'] as String,
      name: map['name'] as String,
      localName: map['local_name'] as String,
      capital: map['capital'] as String,
      tagline: map['tagline'] as String,
      heroImageUrl: map['hero_image_url'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}

/// Cultural category (e.g., Culinary, Dance, Textile)
@immutable
class CulturalCategory {
  final String id;
  final String name;
  final String slug;
  final String iconName;
  final String accentColorKey; // 'saffron', 'teal', 'coral', 'blue'

  const CulturalCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconName,
    required this.accentColorKey,
  });

  factory CulturalCategory.fromMap(Map<String, dynamic> map) {
    return CulturalCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
      iconName: map['icon_name'] as String,
      accentColorKey: map['accent_color_key'] as String,
    );
  }
}

/// Authentic cultural heritage item
@immutable
class CulturalEntry {
  final String id;
  final String categoryId;
  final String title;
  final String localName;
  final String summary;
  final String description;
  final List<String> provinceIds;
  final String imageUrl;
  final bool isUnescoRecognized;

  const CulturalEntry({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.localName,
    required this.summary,
    required this.description,
    required this.provinceIds,
    required this.imageUrl,
    this.isUnescoRecognized = false,
  });

  factory CulturalEntry.fromMap(Map<String, dynamic> map) {
    return CulturalEntry(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      title: map['title'] as String,
      localName: map['local_name'] as String,
      summary: map['summary'] as String,
      description: map['description'] as String,
      provinceIds:
          (map['province_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: map['image_url'] as String,
      isUnescoRecognized: map['is_unesco_recognized'] as bool? ?? false,
    );
  }
}

/// Heritage travel destination
@immutable
class Destination {
  final String id;
  final String title;
  final String provinceId;
  final String cityOrRegency;
  final String tagline;
  final String description;
  final String imageUrl;
  final double rating;
  final String entryFeeRange;
  final bool isFeatured;
  final double latitude;
  final double longitude;

  const Destination({
    required this.id,
    required this.title,
    required this.provinceId,
    required this.cityOrRegency,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.entryFeeRange,
    this.isFeatured = false,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] as String,
      title: map['title'] as String,
      provinceId: map['province_id'] as String,
      cityOrRegency: map['city_or_regency'] as String,
      tagline: map['tagline'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      entryFeeRange: map['entry_fee_range'] as String,
      isFeatured: map['is_featured'] as bool? ?? false,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}

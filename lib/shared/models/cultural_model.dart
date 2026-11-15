import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

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
      id: (map['id'] ?? '').toString().trim(),
      name: (map['name'] ?? '').toString(),
      localName: (map['local_name'] ?? '').toString(),
      capital: (map['capital'] ?? '').toString(),
      tagline: (map['tagline'] ?? '').toString(),
      heroImageUrl: (map['hero_image_url'] ?? '').toString(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
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
      id: (map['id'] ?? '').toString().trim(),
      name: (map['name'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
      iconName: (map['icon_name'] ?? 'category').toString(),
      accentColorKey: (map['accent_color_key'] ?? 'coral').toString(),
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
      id: (map['id'] ?? '').toString().trim(),
      categoryId: (map['category_id'] ?? '').toString().trim(),
      title: (map['title'] ?? '').toString(),
      localName: (map['local_name'] ?? '').toString(),
      summary: (map['summary'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      provinceIds: (map['province_ids'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .toList() ??
          [],
      imageUrl: (map['image_url'] ?? '').toString(),
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
  final String category; // 'structure', 'nature', 'marine', 'village'

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
    this.category = 'structure',
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    final id = (map['id'] ?? '').toString().trim();
    // Check both 'type' and 'category' columns from Supabase, handling whitespace/newlines
    final rawCategory = (map['type'] ?? map['category'] ?? map['destination_type'])
        ?.toString()
        .trim()
        .toLowerCase();

    // Smart fallback if neither type nor category is set in Supabase
    final String category;
    if (rawCategory != null && rawCategory.isNotEmpty) {
      if (rawCategory.contains('nature') ||
          rawCategory.contains('alam') ||
          rawCategory.contains('park') ||
          rawCategory.contains('hutan')) {
        category = 'nature';
      } else if (rawCategory.contains('marine') ||
          rawCategory.contains('bahari') ||
          rawCategory.contains('laut') ||
          rawCategory.contains('pantai') ||
          rawCategory.contains('coastal')) {
        category = 'marine';
      } else if (rawCategory.contains('village') ||
          rawCategory.contains('desa') ||
          rawCategory.contains('kampung')) {
        category = 'village';
      } else if (rawCategory.contains('structure') ||
          rawCategory.contains('heritage') ||
          rawCategory.contains('candi') ||
          rawCategory.contains('bangunan')) {
        category = 'structure';
      } else {
        category = rawCategory;
      }
    } else if (['bromo', 'dieng', 'ujungkulon', 'baluran'].contains(id)) {
      category = 'nature';
    } else if (['bunaken', 'bawean', 'siau'].contains(id)) {
      category = 'marine';
    } else if (['waerebo'].contains(id)) {
      category = 'village';
    } else {
      category = 'structure';
    }

    return Destination(
      id: id,
      title: (map['title'] ?? '').toString(),
      provinceId: (map['province_id'] ?? 'other').toString().trim(),
      cityOrRegency: (map['city_or_regency'] ?? '').toString(),
      tagline: (map['tagline'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      entryFeeRange: (map['entry_fee_range'] ?? 'Free').toString(),
      isFeatured: map['is_featured'] as bool? ?? false,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      category: category,
    );
  }

  /// Readable taxonomy label
  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'nature':
        return 'Nature & Park';
      case 'marine':
        return 'Coastal & Marine';
      case 'village':
        return 'Traditional Village';
      case 'structure':
      default:
        return 'Cultural Heritage';
    }
  }

  /// Category icon for map and badges
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'nature':
        return Icons.landscape_rounded;
      case 'marine':
        return Icons.waves_rounded;
      case 'village':
        return Icons.holiday_village_rounded;
      case 'structure':
      default:
        return Icons.account_balance_rounded;
    }
  }

  /// Primary marker color aligned with Nusantara palette
  Color markerColor(AppColorsExtension colors) {
    switch (category.toLowerCase()) {
      case 'nature':
        return colors.teal;
      case 'marine':
        return colors.blue;
      case 'village':
        return colors.saffron;
      case 'structure':
      default:
        return colors.coral;
    }
  }

  /// Subtle background color for chips and cards
  Color markerSubtleColor(AppColorsExtension colors) {
    switch (category.toLowerCase()) {
      case 'nature':
        return colors.tealSubtle;
      case 'marine':
        return colors.blueSubtle;
      case 'village':
        return colors.saffronSubtle;
      case 'structure':
      default:
        return colors.coralSubtle;
    }
  }
}

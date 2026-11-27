import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/local_settings_service.dart';
import '../../core/services/supabase_config.dart';
import '../../features/discovery/models/itinerary_model.dart';
import '../data/mock_cultural_data.dart';
import '../models/cultural_model.dart';
import 'supabase_cultural_repositories.dart';

/// Contract interface for retrieving cultural data
abstract class CulturalRepository {
  Future<List<Province>> getProvinces();
  Future<List<CulturalCategory>> getCategories();
  Future<List<Destination>> getFeaturedDestinations();
  Future<List<Destination>> getAllDestinations();
  Future<List<CulturalEntry>> getCulturalEntries({String? categoryId});
  Future<List<CulturalEntry>> getCulinaryEntries();
  Future<CulturalEntry?> getCulturalEntryById(String id);
  Future<Destination?> getDestinationById(String id);
}

/// Mock implementation for the foundation phase
class MockCulturalRepository implements CulturalRepository {
  @override
  Future<List<Province>> getProvinces() async {
    // Simulate slight network delay to practice async UI patterns
    await Future.delayed(const Duration(milliseconds: 100));
    return MockCulturalData.provinces;
  }

  @override
  Future<List<CulturalCategory>> getCategories() async {
    return MockCulturalData.categories;
  }

  @override
  Future<List<Destination>> getFeaturedDestinations() async {
    return MockCulturalData.featuredDestinations;
  }

  @override
  Future<List<Destination>> getAllDestinations() async {
    return MockCulturalData.featuredDestinations;
  }

  @override
  Future<List<CulturalEntry>> getCulturalEntries({String? categoryId}) async {
    if (categoryId == null) return MockCulturalData.culturalEntries;
    return MockCulturalData.culturalEntries
        .where((entry) => entry.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<CulturalEntry>> getCulinaryEntries() async {
    return MockCulturalData.culturalEntries
        .where((entry) => entry.categoryId == 'food')
        .toList();
  }

  @override
  Future<CulturalEntry?> getCulturalEntryById(String id) async {
    final cleanId = id.trim().toLowerCase();
    try {
      return MockCulturalData.culturalEntries.firstWhere(
        (entry) => entry.id.trim().toLowerCase() == cleanId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    final cleanId = id.trim().toLowerCase();
    try {
      return MockCulturalData.featuredDestinations.firstWhere(
        (dest) => dest.id.trim().toLowerCase() == cleanId,
      );
    } catch (_) {
      return null;
    }
  }
}

class _BundledCatalog {
  final List<Province> provinces;
  final List<CulturalCategory> categories;
  final List<Destination> destinations;
  final List<CulturalEntry> culturalEntries;

  const _BundledCatalog({
    required this.provinces,
    required this.categories,
    required this.destinations,
    required this.culturalEntries,
  });
}

/// Offline-first repository backed by the bundled JSON catalog in assets/data/.
class LocalCulturalRepository implements CulturalRepository {
  static const String _catalogAssetPath = 'assets/data/cultural_catalog.json';

  _BundledCatalog? _cache;
  Future<_BundledCatalog>? _loadingFuture;

  Future<_BundledCatalog> _loadCatalog() {
    if (_cache != null) return Future.value(_cache!);
    return _loadingFuture ??= _readFromAssets();
  }

  Future<_BundledCatalog> _readFromAssets() async {
    try {
      final raw = await rootBundle.loadString(_catalogAssetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      final provinces = (decoded['provinces'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Province.fromMap)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      final categories = (decoded['categories'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CulturalCategory.fromMap)
          .toList();

      final destinations = (decoded['destinations'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Destination.fromMap)
          .toList();

      final culturalEntries =
          (decoded['cultural_entries'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(CulturalEntry.fromMap)
              .toList();

      _cache = _BundledCatalog(
        provinces: provinces,
        categories: categories,
        destinations: destinations,
        culturalEntries: culturalEntries,
      );
      return _cache!;
    } catch (e) {
      debugPrint('⚠️ Failed to load bundled cultural catalog: $e');
      _loadingFuture = null;
      return const _BundledCatalog(
        provinces: MockCulturalData.provinces,
        categories: MockCulturalData.categories,
        destinations: MockCulturalData.featuredDestinations,
        culturalEntries: MockCulturalData.culturalEntries,
      );
    }
  }

  @override
  Future<List<Province>> getProvinces() async {
    final catalog = await _loadCatalog();
    return catalog.provinces;
  }

  @override
  Future<List<CulturalCategory>> getCategories() async {
    final catalog = await _loadCatalog();
    return catalog.categories;
  }

  @override
  Future<List<Destination>> getFeaturedDestinations() async {
    final catalog = await _loadCatalog();
    return catalog.destinations.where((d) => d.isFeatured).toList();
  }

  @override
  Future<List<Destination>> getAllDestinations() async {
    final catalog = await _loadCatalog();
    return catalog.destinations;
  }

  @override
  Future<List<CulturalEntry>> getCulturalEntries({String? categoryId}) async {
    final catalog = await _loadCatalog();
    if (categoryId == null) return catalog.culturalEntries;
    return catalog.culturalEntries
        .where((entry) => entry.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<CulturalEntry>> getCulinaryEntries() async {
    final catalog = await _loadCatalog();
    return catalog.culturalEntries
        .where((entry) => entry.categoryId == 'food')
        .toList();
  }

  @override
  Future<CulturalEntry?> getCulturalEntryById(String id) async {
    final cleanId = id.trim().toLowerCase();
    final catalog = await _loadCatalog();
    for (final entry in catalog.culturalEntries) {
      if (entry.id.trim().toLowerCase() == cleanId) return entry;
    }
    return null;
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    final cleanId = id.trim().toLowerCase();
    final catalog = await _loadCatalog();
    for (final dest in catalog.destinations) {
      if (dest.id.trim().toLowerCase() == cleanId) return dest;
    }
    return null;
  }
}

// -------------------------------------------------------------
// Riverpod Providers
// -------------------------------------------------------------

/// Provides the active repository implementation (local-first by default; uses
/// Supabase when optional self-hosted credentials are configured).
final culturalRepositoryProvider = Provider<CulturalRepository>((ref) {
  if (SupabaseConfig.isInitialized) {
    return SupabaseCulturalRepository();
  }
  return LocalCulturalRepository();
});

/// FutureProvider for the provinces list
final provincesProvider = FutureProvider<List<Province>>((ref) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getProvinces();
});

/// FutureProvider for featured destinations
final featuredDestinationsProvider = FutureProvider<List<Destination>>((
  ref,
) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getFeaturedDestinations();
});

/// FutureProvider for all destinations (both featured and regular)
final allDestinationsProvider = FutureProvider<List<Destination>>((ref) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getAllDestinations();
});

/// FutureProvider for culinary cultural entries
final culinaryEntriesProvider = FutureProvider<List<CulturalEntry>>((
  ref,
) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getCulinaryEntries();
});

/// FutureProvider for all cultural entries
final culturalEntriesProvider = FutureProvider<List<CulturalEntry>>((
  ref,
) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getCulturalEntries();
});

/// FutureProvider for categories
final categoriesProvider = FutureProvider<List<CulturalCategory>>((ref) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getCategories();
});

/// Tracks the currently selected category slug for browsing (null means "All")
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Provides cultural entries filtered by the active category
final filteredCulturalEntriesProvider = FutureProvider<List<CulturalEntry>>((
  ref,
) async {
  final repository = ref.watch(culturalRepositoryProvider);
  final activeCategory = ref.watch(selectedCategoryFilterProvider);
  return repository.getCulturalEntries(categoryId: activeCategory);
});

/// FutureProvider for a specific cultural entry by ID
final culturalEntryByIdProvider =
    FutureProvider.family<CulturalEntry?, String>((ref, id) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getCulturalEntryById(id);
});

/// FutureProvider for a specific destination by ID
final destinationByIdProvider =
    FutureProvider.family<Destination?, String>((ref, id) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getDestinationById(id);
});

/// Bookmarked heritage item model
class BookmarkItem {
  final String id;
  final String title;
  final String subtitle;
  final String routePath;
  final String? imageUrl;
  final IconData icon;

  const BookmarkItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.routePath,
    this.imageUrl,
    this.icon = Icons.bookmark_rounded,
  });

  static String _iconToKey(IconData icon) {
    if (icon == Icons.restaurant || icon == Icons.restaurant_rounded) {
      return 'restaurant';
    }
    if (icon == Icons.temple_buddhist || icon == Icons.temple_buddhist_rounded) {
      return 'temple';
    }
    if (icon == Icons.landscape_rounded) return 'landscape';
    if (icon == Icons.waves_rounded) return 'waves';
    if (icon == Icons.holiday_village_rounded) return 'village';
    if (icon == Icons.account_balance_rounded) return 'heritage';
    return 'bookmark';
  }

  static IconData _keyToIcon(String? key) {
    switch (key) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'temple':
        return Icons.temple_buddhist_rounded;
      case 'landscape':
        return Icons.landscape_rounded;
      case 'waves':
        return Icons.waves_rounded;
      case 'village':
        return Icons.holiday_village_rounded;
      case 'heritage':
        return Icons.account_balance_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'routePath': routePath,
        'imageUrl': imageUrl,
        'iconKey': _iconToKey(icon),
      };

  factory BookmarkItem.fromMap(Map<String, dynamic> map) {
    return BookmarkItem(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      routePath: (map['routePath'] ?? '').toString(),
      imageUrl: map['imageUrl']?.toString(),
      icon: _keyToIcon(map['iconKey']?.toString()),
    );
  }
}

class BookmarksNotifier extends StateNotifier<List<BookmarkItem>> {
  final SharedPreferences _prefs;

  BookmarksNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  static List<BookmarkItem> _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(LocalStorageKeys.bookmarks);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(BookmarkItem.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _persist() {
    final encoded = jsonEncode(state.map((e) => e.toMap()).toList());
    _prefs.setString(LocalStorageKeys.bookmarks, encoded);
  }

  bool isBookmarked(String id) => state.any((item) => item.id == id);

  bool toggle(BookmarkItem item) {
    if (isBookmarked(item.id)) {
      state = state.where((b) => b.id != item.id).toList();
      _persist();
      return false;
    } else {
      state = [...state, item];
      _persist();
      return true;
    }
  }

  void removeById(String id) {
    state = state.where((b) => b.id != id).toList();
    _persist();
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<BookmarkItem>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BookmarksNotifier(prefs);
});

class SavedItinerariesNotifier extends StateNotifier<List<ItineraryPlan>> {
  final SharedPreferences _prefs;

  SavedItinerariesNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  static List<ItineraryPlan> _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(LocalStorageKeys.savedItineraries);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ItineraryPlan.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _persist() {
    final encoded = jsonEncode(state.map((p) => p.toMap()).toList());
    _prefs.setString(LocalStorageKeys.savedItineraries, encoded);
  }

  bool isSaved(ItineraryPlan plan) =>
      state.any((item) => item.storageKey == plan.storageKey);

  bool toggle(ItineraryPlan plan) {
    if (isSaved(plan)) {
      state = state.where((item) => item.storageKey != plan.storageKey).toList();
      _persist();
      return false;
    } else {
      state = [plan, ...state];
      _persist();
      return true;
    }
  }

  void remove(String storageKey) {
    state = state.where((item) => item.storageKey != storageKey).toList();
    _persist();
  }
}

final savedItinerariesProvider =
    StateNotifierProvider<SavedItinerariesNotifier, List<ItineraryPlan>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SavedItinerariesNotifier(prefs);
});

class CulturalPassionsNotifier extends StateNotifier<List<String>> {
  static const List<String> defaultPassions = [
    'Batik & Weaving',
    'Ancient Candi',
    'Royal Keraton',
    'Traditional Culinary',
    'Gamelan & Music',
    'Wayang Heritage',
  ];

  final SharedPreferences _prefs;

  CulturalPassionsNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  static List<String> _loadFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getStringList(LocalStorageKeys.culturalPassions);
    if (saved == null || saved.isEmpty) return defaultPassions;
    return saved;
  }

  void togglePassion(String passion) {
    if (state.contains(passion)) {
      if (state.length <= 1) return; // Keep at least one passion active
      state = state.where((p) => p != passion).toList();
    } else {
      state = [...state, passion];
    }
    _prefs.setStringList(LocalStorageKeys.culturalPassions, state);
  }
}

final culturalPassionsProvider =
    StateNotifierProvider<CulturalPassionsNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CulturalPassionsNotifier(prefs);
});

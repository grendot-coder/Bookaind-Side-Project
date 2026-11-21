import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// -------------------------------------------------------------
// Riverpod Providers
// -------------------------------------------------------------

/// Provides the active repository implementation (currently Mock, later Supabase)
final culturalRepositoryProvider = Provider<CulturalRepository>((ref) {
  return SupabaseCulturalRepository(); // <--- Now powered by Supabase!
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
}

// shortcut: in-memory bookmark store, upgrade to Supabase table when user cloud sync is required
class BookmarksNotifier extends StateNotifier<List<BookmarkItem>> {
  BookmarksNotifier() : super(const []);

  bool isBookmarked(String id) => state.any((item) => item.id == id);

  bool toggle(BookmarkItem item) {
    if (isBookmarked(item.id)) {
      state = state.where((b) => b.id != item.id).toList();
      return false;
    } else {
      state = [...state, item];
      return true;
    }
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<BookmarkItem>>((ref) {
  return BookmarksNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_cultural_data.dart';
import '../models/cultural_model.dart';
import 'supabase_cultural_repositories.dart';

/// Contract interface for retrieving cultural data
abstract class CulturalRepository {
  Future<List<Province>> getProvinces();
  Future<List<CulturalCategory>> getCategories();
  Future<List<Destination>> getFeaturedDestinations();
  Future<List<CulturalEntry>> getCulturalEntries({String? categoryId});
  Future<List<CulturalEntry>> getCulinaryEntries();
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

/// FutureProvider for culinary cultural entries
final culinaryEntriesProvider = FutureProvider<List<CulturalEntry>>((
  ref,
) async {
  final repository = ref.watch(culturalRepositoryProvider);
  return repository.getCulinaryEntries();
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

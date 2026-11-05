import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_cultural_data.dart';
import '../models/cultural_model.dart';
import 'cultural_repositories.dart';

class SupabaseCulturalRepository implements CulturalRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Province>> getProvinces() async {
    try {
      final response = await _client
          .from('provinces')
          .select()
          .order('name', ascending: true);
      return (response as List).map((row) => Province.fromMap(row)).toList();
    } catch (_) {
      // Offline fallback
      return MockCulturalData.provinces;
    }
  }

  @override
  Future<List<CulturalCategory>> getCategories() async {
    try {
      final response = await _client.from('cultural_categories').select();
      return (response as List)
          .map((row) => CulturalCategory.fromMap(row))
          .toList();
    } catch (_) {
      return MockCulturalData.categories;
    }
  }

  @override
  Future<List<Destination>> getFeaturedDestinations() async {
    try {
      final response = await _client
          .from('destinations')
          .select()
          .eq('is_featured', true);
      return (response as List).map((row) => Destination.fromMap(row)).toList();
    } catch (_) {
      return MockCulturalData.featuredDestinations;
    }
  }

  @override
  Future<List<CulturalEntry>> getCulturalEntries({String? categoryId}) async {
    try {
      var query = _client.from('cultural_entries').select();
      final response = categoryId != null
          ? await query.eq('category_id', categoryId)
          : await query;
      return (response as List)
          .map((row) => CulturalEntry.fromMap(row))
          .toList();
    } catch (_) {
      if (categoryId == null) return MockCulturalData.culturalEntries;
      return MockCulturalData.culturalEntries
          .where((e) => e.categoryId == categoryId)
          .toList();
    }
  }

  @override
  Future<List<CulturalEntry>> getCulinaryEntries() async {
    try {
      final response = await _client
          .from('cultural_entries')
          .select()
          .eq('category_id', 'food');
      return (response as List)
          .map((row) => CulturalEntry.fromMap(row))
          .toList();
    } catch (_) {
      return MockCulturalData.culturalEntries
          .where((e) => e.categoryId == 'food')
          .toList();
    }
  }
}

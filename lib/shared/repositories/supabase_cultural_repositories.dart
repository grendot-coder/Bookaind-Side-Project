import 'package:flutter/foundation.dart';
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
    } catch (e) {
      debugPrint('⚠️ Supabase getFeaturedDestinations error: $e');
      return MockCulturalData.featuredDestinations;
    }
  }

  @override
  Future<List<Destination>> getAllDestinations() async {
    try {
      final response = await _client.from('destinations').select();
      return (response as List).map((row) => Destination.fromMap(row)).toList();
    } catch (e) {
      debugPrint('⚠️ Supabase getAllDestinations error: $e');
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
    } catch (e) {
      debugPrint('⚠️ Supabase getCulturalEntries error: $e');
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
    } catch (e) {
      debugPrint('⚠️ Supabase getCulinaryEntries error: $e');
      return MockCulturalData.culturalEntries
          .where((e) => e.categoryId == 'food')
          .toList();
    }
  }

  @override
  Future<CulturalEntry?> getCulturalEntryById(String id) async {
    final cleanId = id.trim().toLowerCase();
    try {
      final response = await _client
          .from('cultural_entries')
          .select()
          .ilike('id', cleanId)
          .maybeSingle();

      if (response != null) {
        return CulturalEntry.fromMap(response);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getCulturalEntryById error: $e');
    }

    // Fallback to mock data if offline or not found
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
      final response = await _client
          .from('destinations')
          .select()
          .ilike('id', cleanId)
          .maybeSingle();

      if (response != null) {
        return Destination.fromMap(response);
      }
    } catch (e) {
      debugPrint('⚠️ Supabase getDestinationById error: $e');
    }

    // Fallback to mock data
    try {
      return MockCulturalData.featuredDestinations.firstWhere(
        (dest) => dest.id.trim().toLowerCase() == cleanId,
      );
    } catch (_) {
      return null;
    }
  }
}

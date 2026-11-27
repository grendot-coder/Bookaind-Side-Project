import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_config.dart';
import '../models/cultural_model.dart';
import 'cultural_repositories.dart';

class SupabaseCulturalRepository implements CulturalRepository {
  SupabaseClient? get _client => SupabaseConfig.clientOrNull;
  final LocalCulturalRepository _localFallback = LocalCulturalRepository();

  @override
  Future<List<Province>> getProvinces() async {
    final client = _client;
    if (client == null) return _localFallback.getProvinces();
    try {
      final response = await client
          .from('provinces')
          .select()
          .order('name', ascending: true);
      return (response as List).map((row) => Province.fromMap(row)).toList();
    } catch (_) {
      return _localFallback.getProvinces();
    }
  }

  @override
  Future<List<CulturalCategory>> getCategories() async {
    final client = _client;
    if (client == null) return _localFallback.getCategories();
    try {
      final response = await client.from('cultural_categories').select();
      return (response as List)
          .map((row) => CulturalCategory.fromMap(row))
          .toList();
    } catch (_) {
      return _localFallback.getCategories();
    }
  }

  @override
  Future<List<Destination>> getFeaturedDestinations() async {
    final client = _client;
    if (client == null) return _localFallback.getFeaturedDestinations();
    try {
      final response = await client
          .from('destinations')
          .select()
          .eq('is_featured', true);
      return (response as List).map((row) => Destination.fromMap(row)).toList();
    } catch (e) {
      debugPrint('⚠️ Supabase getFeaturedDestinations error: $e');
      return _localFallback.getFeaturedDestinations();
    }
  }

  @override
  Future<List<Destination>> getAllDestinations() async {
    final client = _client;
    if (client == null) return _localFallback.getAllDestinations();
    try {
      final response = await client.from('destinations').select();
      return (response as List).map((row) => Destination.fromMap(row)).toList();
    } catch (e) {
      debugPrint('⚠️ Supabase getAllDestinations error: $e');
      return _localFallback.getAllDestinations();
    }
  }

  @override
  Future<List<CulturalEntry>> getCulturalEntries({String? categoryId}) async {
    final client = _client;
    if (client == null) {
      return _localFallback.getCulturalEntries(categoryId: categoryId);
    }
    try {
      var query = client.from('cultural_entries').select();
      final response = categoryId != null
          ? await query.eq('category_id', categoryId)
          : await query;
      return (response as List)
          .map((row) => CulturalEntry.fromMap(row))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Supabase getCulturalEntries error: $e');
      return _localFallback.getCulturalEntries(categoryId: categoryId);
    }
  }

  @override
  Future<List<CulturalEntry>> getCulinaryEntries() async {
    final client = _client;
    if (client == null) return _localFallback.getCulinaryEntries();
    try {
      final response = await client
          .from('cultural_entries')
          .select()
          .eq('category_id', 'food');
      return (response as List)
          .map((row) => CulturalEntry.fromMap(row))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Supabase getCulinaryEntries error: $e');
      return _localFallback.getCulinaryEntries();
    }
  }

  @override
  Future<CulturalEntry?> getCulturalEntryById(String id) async {
    final client = _client;
    if (client == null) return _localFallback.getCulturalEntryById(id);
    final cleanId = id.trim().toLowerCase();
    try {
      final response = await client
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

    return _localFallback.getCulturalEntryById(id);
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    final client = _client;
    if (client == null) return _localFallback.getDestinationById(id);
    final cleanId = id.trim().toLowerCase();
    try {
      final response = await client
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

    return _localFallback.getDestinationById(id);
  }
}

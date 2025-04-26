import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/facility.dart';

class FacilityService {
  final _supabase = Supabase.instance.client;

  Future<List<Facility>> getFacilities() async {
    try {
      final response =
          await _supabase.from('facilities').select().order('name');

      return (response as List).map((item) => Facility.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load facilities: $e');
    }
  }

  Future<Facility> getFacilityById(String id) async {
    try {
      final response =
          await _supabase.from('facilities').select().eq('id', id).single();

      return Facility.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load facility: $e');
    }
  }

  Future<List<Facility>> searchFacilities(String query) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name');

      return (response as List).map((item) => Facility.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search facilities: $e');
    }
  }

  Future<List<Facility>> filterFacilitiesByTag(String tag) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .contains('tags', [tag]).order('name');

      return (response as List).map((item) => Facility.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to filter facilities: $e');
    }
  }

  // Create a new facility
  Future<Facility> createFacility(Facility facility) async {
    try {
      final response = await _supabase
          .from('facilities')
          .insert(facility.toJson())
          .select()
          .single();

      return Facility.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create facility: $e');
    }
  }

  // Update an existing facility
  Future<Facility> updateFacility(Facility facility) async {
    try {
      final response = await _supabase
          .from('facilities')
          .update(facility.toJson())
          .eq('id', facility.id)
          .select()
          .single();

      return Facility.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update facility: $e');
    }
  }

  // Delete a facility
  Future<void> deleteFacility(String id) async {
    try {
      await _supabase.from('facilities').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete facility: $e');
    }
  }
}

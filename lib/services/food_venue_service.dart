import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_venue.dart';

class FoodVenueService {
  final _supabase = Supabase.instance.client;

  Future<List<FoodVenue>> getFoodVenues() async {
    try {
      final response = await _supabase
          .from('food_venues')
          .select('*, menu_items(*)')
          .order('name');

      return (response as List).map((item) {
        // Convert menu_items from the response to the expected format
        if (item['menu_items'] != null) {
          item['menu'] = item['menu_items'];
          item.remove('menu_items');
        } else {
          item['menu'] = [];
        }
        return FoodVenue.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load food venues: $e');
    }
  }

  Future<FoodVenue> getFoodVenueById(String id) async {
    try {
      final response = await _supabase
          .from('food_venues')
          .select('*, menu_items(*)')
          .eq('id', id)
          .single();

      // Convert menu_items from the response to the expected format
      if (response['menu_items'] != null) {
        response['menu'] = response['menu_items'];
        response.remove('menu_items');
      } else {
        response['menu'] = [];
      }

      return FoodVenue.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load food venue: $e');
    }
  }

  Future<List<FoodVenue>> searchFoodVenues(String query) async {
    try {
      final response = await _supabase
          .from('food_venues')
          .select('*, menu_items(*)')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name');

      return (response as List).map((item) {
        // Convert menu_items from the response to the expected format
        if (item['menu_items'] != null) {
          item['menu'] = item['menu_items'];
          item.remove('menu_items');
        } else {
          item['menu'] = [];
        }
        return FoodVenue.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search food venues: $e');
    }
  }

  Future<List<FoodVenue>> filterByCuisine(String cuisine) async {
    try {
      final response = await _supabase
          .from('food_venues')
          .select('*, menu_items(*)')
          .contains('cuisine_types', [cuisine]).order('name');

      return (response as List).map((item) {
        // Convert menu_items from the response to the expected format
        if (item['menu_items'] != null) {
          item['menu'] = item['menu_items'];
          item.remove('menu_items');
        } else {
          item['menu'] = [];
        }
        return FoodVenue.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter food venues: $e');
    }
  }

  // Create a new food venue
  Future<FoodVenue> createFoodVenue(FoodVenue venue) async {
    try {
      // First, create the venue without the menu items
      final venueData = venue.toJson();
      venueData.remove('menu');

      final response = await _supabase
          .from('food_venues')
          .insert(venueData)
          .select()
          .single();

      final String venueId = response['id'];

      // Now add the menu items if any exist
      if (venue.menu.isNotEmpty) {
        final menuItems = venue.menu.map((item) {
          final menuItemData = item.toJson();
          menuItemData['venue_id'] = venueId;
          return menuItemData;
        }).toList();

        await _supabase.from('menu_items').insert(menuItems);
      }

      // Fetch the complete venue with menu items
      return await getFoodVenueById(venueId);
    } catch (e) {
      throw Exception('Failed to create food venue: $e');
    }
  }

  // Update an existing food venue
  Future<FoodVenue> updateFoodVenue(FoodVenue venue) async {
    try {
      // First, update the venue without the menu items
      final venueData = venue.toJson();
      venueData.remove('menu');

      await _supabase.from('food_venues').update(venueData).eq('id', venue.id);

      // Delete existing menu items
      await _supabase.from('menu_items').delete().eq('venue_id', venue.id);

      // Add the updated menu items if any exist
      if (venue.menu.isNotEmpty) {
        final menuItems = venue.menu.map((item) {
          final menuItemData = item.toJson();
          menuItemData['venue_id'] = venue.id;
          return menuItemData;
        }).toList();

        await _supabase.from('menu_items').insert(menuItems);
      }

      // Fetch the updated venue with menu items
      return await getFoodVenueById(venue.id);
    } catch (e) {
      throw Exception('Failed to update food venue: $e');
    }
  }

  // Delete a food venue
  Future<void> deleteFoodVenue(String id) async {
    try {
      // First delete the menu items (Supabase will handle this with cascading deletes if configured)
      await _supabase.from('menu_items').delete().eq('venue_id', id);

      // Then delete the venue
      await _supabase.from('food_venues').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete food venue: $e');
    }
  }
}

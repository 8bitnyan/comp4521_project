import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Helper class to generate and insert mock data into Supabase
class MockDataGenerator {
  final _supabase = Supabase.instance.client;

  /// Check if we can access the required tables in Supabase
  Future<Map<String, bool>> checkDatabaseAccess() async {
    final result = <String, bool>{};

    try {
      // Check facilities table
      await _supabase.from('facilities').select('id').limit(1);
      result['facilities'] = true;
    } catch (e) {
      debugPrint('Cannot access facilities table: $e');
      result['facilities'] = false;
    }

    try {
      // Check food_venues table
      await _supabase.from('food_venues').select('id').limit(1);
      result['food_venues'] = true;
    } catch (e) {
      debugPrint('Cannot access food_venues table: $e');
      result['food_venues'] = false;
    }

    try {
      // Check menu_items table
      await _supabase.from('menu_items').select('id').limit(1);
      result['menu_items'] = true;
    } catch (e) {
      debugPrint('Cannot access menu_items table: $e');
      result['menu_items'] = false;
    }

    try {
      // Check events table
      await _supabase.from('events').select('id').limit(1);
      result['events'] = true;
    } catch (e) {
      debugPrint('Cannot access events table: $e');
      result['events'] = false;
    }

    return result;
  }

  /// Generate and insert mock facilities
  Future<bool> insertMockFacilities() async {
    try {
      debugPrint('Starting to insert mock facilities...');

      // Check if we can access the table first
      try {
        await _supabase.from('facilities').select('id').limit(1);
        debugPrint('Successfully connected to facilities table');
      } catch (e) {
        debugPrint('Failed to connect to facilities table: $e');
        return false;
      }

      // Clear existing facilities first (optional)
      try {
        // Delete all existing records
        await _supabase.from('facilities').delete().not('id', 'is', null);
        debugPrint('Cleared existing facilities');
      } catch (e) {
        debugPrint('Failed to clear existing facilities: $e');
        // Continue anyway, this might fail if there are no records
      }

      // Insert new facilities
      final facilities = [
        {
          'name': 'Main Library',
          'description': 'The central library with study spaces and resources',
          'image_url': 'https://picsum.photos/800/600?random=1',
          'building_code': 'AB1',
          'floor': 'G',
          'operating_hours': '8:00 AM - 11:00 PM',
          'contact_info': '+852 2358 1234',
          'latitude': 22.3363,
          'longitude': 114.2634,
          'current_occupancy': 200,
          'max_occupancy': 500,
          'tags': ['study', 'books', 'quiet'],
        },
        {
          'name': 'Sports Center',
          'description': 'Multi-purpose sports facility with gym and courts',
          'image_url': 'https://picsum.photos/800/600?random=2',
          'building_code': 'SC',
          'floor': '1',
          'operating_hours': '7:00 AM - 10:00 PM',
          'contact_info': '+852 2358 5678',
          'latitude': 22.3373,
          'longitude': 114.2639,
          'current_occupancy': 150,
          'max_occupancy': 300,
          'tags': ['sports', 'fitness', 'recreation'],
        },
        {
          'name': 'Computer Lab A',
          'description': 'Computer lab with high-performance workstations',
          'image_url': 'https://picsum.photos/800/600?random=3',
          'building_code': 'AB3',
          'floor': '4',
          'operating_hours': '9:00 AM - 9:00 PM',
          'contact_info': '+852 2358 9012',
          'latitude': 22.3358,
          'longitude': 114.2630,
          'current_occupancy': 25,
          'max_occupancy': 80,
          'tags': ['computers', 'study', 'tech'],
        },
        {
          'name': 'Student Lounge',
          'description':
              'Relaxation area for students with comfortable seating',
          'image_url': 'https://picsum.photos/800/600?random=4',
          'building_code': 'SC',
          'floor': '2',
          'operating_hours': '8:00 AM - 8:00 PM',
          'contact_info': '+852 2358 3456',
          'latitude': 22.3365,
          'longitude': 114.2642,
          'current_occupancy': 80,
          'max_occupancy': 120,
          'tags': ['relaxation', 'social', 'food'],
        },
        {
          'name': 'Lecture Hall A',
          'description': 'Large lecture hall with modern AV equipment',
          'image_url': 'https://picsum.photos/800/600?random=5',
          'building_code': 'AB1',
          'floor': '4',
          'operating_hours': '8:00 AM - 6:00 PM',
          'contact_info': '+852 2358 7890',
          'latitude': 22.3361,
          'longitude': 114.2636,
          'current_occupancy': 125,
          'max_occupancy': 250,
          'tags': ['lecture', 'class', 'presentation'],
        },
      ];

      // Insert new facilities one by one to see which one fails
      var successCount = 0;
      for (var facility in facilities) {
        try {
          await _supabase.from('facilities').insert(facility);
          successCount++;
          debugPrint('Inserted facility: ${facility['name']}');
        } catch (e) {
          debugPrint('Failed to insert facility ${facility['name']}: $e');
        }
      }

      debugPrint(
          'Mock facilities inserted: $successCount/${facilities.length}');
      return successCount > 0;
    } catch (e) {
      debugPrint('Error inserting mock facilities: $e');
      return false;
    }
  }

  /// Generate and insert mock food venues
  Future<bool> insertMockFoodVenues() async {
    try {
      debugPrint('Starting to insert mock food venues...');

      // Check if we can access the tables first
      try {
        await _supabase.from('food_venues').select('id').limit(1);
        await _supabase.from('menu_items').select('id').limit(1);
        debugPrint(
            'Successfully connected to food_venues and menu_items tables');
      } catch (e) {
        debugPrint('Failed to connect to food_venues or menu_items tables: $e');
        return false;
      }

      // Clear existing food venues first (optional)
      try {
        // Delete all existing records
        await _supabase.from('food_venues').delete().not('id', 'is', null);
        debugPrint('Cleared existing food venues');
      } catch (e) {
        debugPrint('Failed to clear existing food venues: $e');
        // Continue anyway
      }

      // Clear existing menu items (to avoid orphaned items)
      try {
        // Delete all existing records
        await _supabase.from('menu_items').delete().not('id', 'is', null);
        debugPrint('Cleared existing menu items');
      } catch (e) {
        debugPrint('Failed to clear existing menu items: $e');
        // Continue anyway
      }

      // Insert new food venues and their menu items
      final foodVenues = [
        {
          'name': 'Campus Café',
          'description':
              'Casual café serving coffee, sandwiches, and light meals',
          'image_url': 'https://picsum.photos/800/600?random=6',
          'building_code': 'SC',
          'floor': '1',
          'operating_hours': '7:30 AM - 8:00 PM',
          'contact_info': '+852 2358 1234',
          'latitude': 22.3366,
          'longitude': 114.2640,
          'rating': 4.2,
          'num_ratings': 125,
          'cuisine_types': ['Café', 'Western', 'Sandwiches'],
          'menu_items': [
            {
              'name': 'Breakfast Sandwich',
              'description': 'Egg, cheese, and bacon on a croissant',
              'price': 45.0,
              'image_url': 'https://picsum.photos/800/600?random=7',
              'is_vegetarian': false,
              'is_vegan': false,
              'is_gluten_free': false,
            },
            {
              'name': 'Caesar Salad',
              'description': 'Fresh romaine lettuce with Caesar dressing',
              'price': 55.0,
              'image_url': 'https://picsum.photos/800/600?random=8',
              'is_vegetarian': true,
              'is_vegan': false,
              'is_gluten_free': false,
            },
            {
              'name': 'Cappuccino',
              'description': 'Espresso with steamed milk and foam',
              'price': 30.0,
              'image_url': 'https://picsum.photos/800/600?random=9',
              'is_vegetarian': true,
              'is_vegan': false,
              'is_gluten_free': true,
            },
          ],
        },
        {
          'name': 'Asian Delight',
          'description':
              'Authentic Asian cuisine featuring dishes from across Asia',
          'image_url': 'https://picsum.photos/800/600?random=10',
          'building_code': 'AB2',
          'floor': 'G',
          'operating_hours': '11:00 AM - 9:00 PM',
          'contact_info': '+852 2358 2345',
          'latitude': 22.3360,
          'longitude': 114.2638,
          'rating': 4.5,
          'num_ratings': 210,
          'cuisine_types': ['Chinese', 'Japanese', 'Thai'],
          'menu_items': [
            {
              'name': 'Dim Sum Platter',
              'description': 'Assortment of steamed dumplings',
              'price': 68.0,
              'image_url': 'https://picsum.photos/800/600?random=11',
              'is_vegetarian': false,
              'is_vegan': false,
              'is_gluten_free': false,
            },
            {
              'name': 'Pad Thai',
              'description': 'Thai stir-fried noodles with shrimp',
              'price': 75.0,
              'image_url': 'https://picsum.photos/800/600?random=12',
              'is_vegetarian': false,
              'is_vegan': false,
              'is_gluten_free': false,
            },
            {
              'name': 'Matcha Ice Cream',
              'description': 'Creamy green tea ice cream',
              'price': 35.0,
              'image_url': 'https://picsum.photos/800/600?random=13',
              'is_vegetarian': true,
              'is_vegan': false,
              'is_gluten_free': true,
            },
          ],
        },
        {
          'name': 'Healthy Bowl',
          'description': 'Nutritious grain bowls, salads, and smoothies',
          'image_url': 'https://picsum.photos/800/600?random=14',
          'building_code': 'SC',
          'floor': 'G',
          'operating_hours': '8:00 AM - 7:00 PM',
          'contact_info': '+852 2358 3456',
          'latitude': 22.3371,
          'longitude': 114.2637,
          'rating': 4.8,
          'num_ratings': 95,
          'cuisine_types': ['Healthy', 'Vegetarian', 'Vegan'],
          'menu_items': [
            {
              'name': 'Protein Power Bowl',
              'description': 'Quinoa, grilled chicken, and vegetables',
              'price': 85.0,
              'image_url': 'https://picsum.photos/800/600?random=15',
              'is_vegetarian': false,
              'is_vegan': false,
              'is_gluten_free': true,
            },
            {
              'name': 'Green Goddess Salad',
              'description': 'Mixed greens with avocado and tahini dressing',
              'price': 70.0,
              'image_url': 'https://picsum.photos/800/600?random=16',
              'is_vegetarian': true,
              'is_vegan': true,
              'is_gluten_free': true,
            },
            {
              'name': 'Berry Blast Smoothie',
              'description': 'Mixed berries with yogurt and honey',
              'price': 48.0,
              'image_url': 'https://picsum.photos/800/600?random=17',
              'is_vegetarian': true,
              'is_vegan': false,
              'is_gluten_free': true,
            },
          ],
        },
      ];

      // Insert new food venues and their menu items
      var successCount = 0;
      for (var venue in foodVenues) {
        try {
          final menuItems = venue.remove('menu_items') as List;

          final response = await _supabase
              .from('food_venues')
              .insert(venue)
              .select()
              .single();

          final String venueId = response['id'];
          debugPrint('Inserted food venue: ${venue['name']} with ID: $venueId');

          // Insert menu items linked to the venue
          var menuItemsSuccess = 0;
          for (var item in menuItems) {
            try {
              item['venue_id'] = venueId;
              await _supabase.from('menu_items').insert(item);
              menuItemsSuccess++;
            } catch (e) {
              debugPrint('Failed to insert menu item for venue $venueId: $e');
            }
          }

          debugPrint(
              'Inserted $menuItemsSuccess/${menuItems.length} menu items for venue: ${venue['name']}');
          successCount++;
        } catch (e) {
          debugPrint('Failed to insert food venue ${venue['name']}: $e');
        }
      }

      debugPrint(
          'Mock food venues inserted: $successCount/${foodVenues.length}');
      return successCount > 0;
    } catch (e) {
      debugPrint('Error inserting mock food venues: $e');
      return false;
    }
  }

  /// Generate and insert mock events
  Future<bool> insertMockEvents() async {
    try {
      debugPrint('Starting to insert mock events...');

      // Check if we can access the table first
      try {
        await _supabase.from('events').select('id').limit(1);
        debugPrint('Successfully connected to events table');
      } catch (e) {
        debugPrint('Failed to connect to events table: $e');
        return false;
      }

      // Create events starting from today
      final now = DateTime.now();

      // Clear existing events first (optional)
      try {
        // Delete all existing records
        await _supabase.from('events').delete().not('id', 'is', null);
        debugPrint('Cleared existing events');
      } catch (e) {
        debugPrint('Failed to clear existing events: $e');
        // Continue anyway
      }

      // Insert new events
      final events = [
        {
          'title': 'Welcome Day',
          'description': 'Orientation program for new students',
          'start_time': DateTime(now.year, now.month, now.day + 2, 9, 0)
              .toIso8601String(),
          'end_time': DateTime(now.year, now.month, now.day + 2, 17, 0)
              .toIso8601String(),
          'location': 'University Piazza',
          'image_url': 'https://picsum.photos/800/600?random=18',
          'type': 'Orientation',
          'organizer': 'Student Affairs Office',
        },
        {
          'title': 'Tech Talk: AI and the Future',
          'description':
              'Discussion on the latest developments in AI technology',
          'start_time': DateTime(now.year, now.month, now.day + 5, 14, 0)
              .toIso8601String(),
          'end_time': DateTime(now.year, now.month, now.day + 5, 16, 0)
              .toIso8601String(),
          'location': 'Lecture Hall A, Academic Building 1',
          'image_url': 'https://picsum.photos/800/600?random=19',
          'type': 'Academic',
          'organizer': 'Computer Science Department',
        },
        {
          'title': 'Campus Sports Day',
          'description':
              'Annual sports competition with various athletic events',
          'start_time': DateTime(now.year, now.month, now.day + 10, 10, 0)
              .toIso8601String(),
          'end_time': DateTime(now.year, now.month, now.day + 10, 18, 0)
              .toIso8601String(),
          'location': 'Sports Center',
          'image_url': 'https://picsum.photos/800/600?random=20',
          'type': 'Sports',
          'organizer': 'Physical Education Department',
        },
        {
          'title': 'Career Fair 2023',
          'description':
              'Meet with potential employers and explore career opportunities',
          'start_time': DateTime(now.year, now.month, now.day + 15, 10, 0)
              .toIso8601String(),
          'end_time': DateTime(now.year, now.month, now.day + 15, 16, 0)
              .toIso8601String(),
          'location': 'Multi-purpose Hall, Student Center',
          'image_url': 'https://picsum.photos/800/600?random=21',
          'type': 'Career',
          'organizer': 'Career Development Center',
        },
        {
          'title': 'Cultural Night',
          'description':
              'Celebration of diverse cultures with performances and food',
          'start_time': DateTime(now.year, now.month, now.day + 20, 18, 0)
              .toIso8601String(),
          'end_time': DateTime(now.year, now.month, now.day + 20, 22, 0)
              .toIso8601String(),
          'location': 'University Piazza',
          'image_url': 'https://picsum.photos/800/600?random=22',
          'type': 'Cultural',
          'organizer': 'Student Union',
        },
      ];

      // Insert new events
      var successCount = 0;
      for (var event in events) {
        try {
          await _supabase.from('events').insert(event);
          successCount++;
          debugPrint('Inserted event: ${event['title']}');
        } catch (e) {
          debugPrint('Failed to insert event ${event['title']}: $e');
        }
      }

      debugPrint('Mock events inserted: $successCount/${events.length}');
      return successCount > 0;
    } catch (e) {
      debugPrint('Error inserting mock events: $e');
      return false;
    }
  }

  /// Insert all mock data with verification
  Future<Map<String, bool>> insertAllMockData() async {
    final results = <String, bool>{};

    // First check DB access
    final accessCheck = await checkDatabaseAccess();
    if (accessCheck.values.any((canAccess) => !canAccess)) {
      debugPrint('Database access check failed: $accessCheck');
      return {'database_access': false};
    }

    // Insert data
    results['facilities'] = await insertMockFacilities();
    results['food_venues'] = await insertMockFoodVenues();
    results['events'] = await insertMockEvents();

    // Overall success
    final success = results.values.every((result) => result);
    debugPrint('All mock data insertion complete. Success: $success');

    return results;
  }
}

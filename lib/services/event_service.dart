import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventService {
  final _supabase = Supabase.instance.client;

  Future<List<Event>> fetchEvents() async {
    try {
      final response =
          await _supabase.from('events').select().order('start_time');

      return (response as List).map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<List<Event>> fetchUpcomingEvents() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final response = await _supabase
          .from('events')
          .select()
          .gte('start_time', now)
          .order('start_time');

      return (response as List).map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load upcoming events: $e');
    }
  }

  Future<Event> fetchEventById(String id) async {
    try {
      final response =
          await _supabase.from('events').select().eq('id', id).single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load event: $e');
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%,type.ilike.%$query%')
          .order('start_time');

      return (response as List).map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  Future<List<Event>> filterEventsByType(String type) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('type', type)
          .order('start_time');

      return (response as List).map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to filter events: $e');
    }
  }

  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      final startStr = start.toUtc().toIso8601String();
      final endStr = end.toUtc().toIso8601String();

      final response = await _supabase
          .from('events')
          .select()
          .gte('start_time', startStr)
          .lte('start_time', endStr)
          .order('start_time');

      return (response as List).map((item) => Event.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load events by date range: $e');
    }
  }

  Future<Event> createEvent(Event event) async {
    try {
      final response = await _supabase
          .from('events')
          .insert(event.toJson())
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      final response = await _supabase
          .from('events')
          .update(event.toJson())
          .eq('id', event.id)
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _supabase.from('events').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<void> registerForEvent(String userId, String eventId) async {
    try {
      await _supabase.from('user_event_registrations').insert({
        'user_id': userId,
        'event_id': eventId,
      });
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  Future<void> unregisterFromEvent(String userId, String eventId) async {
    try {
      await _supabase
          .from('user_event_registrations')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);
    } catch (e) {
      throw Exception('Failed to unregister from event: $e');
    }
  }

  Future<List<String>> getUserRegisteredEvents(String userId) async {
    try {
      final response = await _supabase
          .from('user_event_registrations')
          .select('event_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['event_id'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to load user registered events: $e');
    }
  }
}

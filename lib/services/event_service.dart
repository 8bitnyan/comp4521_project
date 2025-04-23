import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventService {
  final _client = Supabase.instance.client;

  Future<List<Event>> fetchEvents() async {
    final response = await _client
        .from('events')
        .select()
        .order('start_time', ascending: true);

    return (response as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

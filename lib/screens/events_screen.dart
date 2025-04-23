import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = EventService().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Events')),
      body: FutureBuilder<List<Event>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events found.'));
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, i) {
              final event = events[i];
              return ListTile(
                leading: event.imageUrl != null
                    ? Image.network(event.imageUrl!,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.event),
                title: Text(event.title),
                subtitle: Text(event.description ?? ''),
                trailing: event.startTime != null
                    ? Text('${event.startTime!.month}/${event.startTime!.day}')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

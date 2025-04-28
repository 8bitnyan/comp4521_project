import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  List<Event> _events = [];
  Map<DateTime, List<Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock events data
    final List<Event> events = [
      Event(
        id: '1',
        title: 'University Orientation',
        description: 'Welcome session for new students',
        startTime: DateTime.now()
            .add(const Duration(days: 2))
            .copyWith(hour: 10, minute: 0),
        endTime: DateTime.now()
            .add(const Duration(days: 2))
            .copyWith(hour: 12, minute: 0),
        location: 'Main Auditorium',
        organizer: 'Student Affairs Office',
        type: 'Orientation',
        imageUrl:
            'https://www.ust.hk/sites/default/files/styles/page_content_desktop_x1/public/2019-06/HKUST_aerial.jpeg',
      ),
      Event(
        id: '2',
        title: 'Career Fair',
        description: 'Annual career fair with over 50 companies',
        startTime: DateTime.now()
            .add(const Duration(days: 5))
            .copyWith(hour: 10, minute: 0),
        endTime: DateTime.now()
            .add(const Duration(days: 5))
            .copyWith(hour: 17, minute: 0),
        location: 'Sports Hall',
        organizer: 'Career Center',
        type: 'Career',
        imageUrl:
            'https://career.ust.hk/sites/career.ust.hk/files/styles/front_page_slider_image_desktop/public/banner_4.jpg',
      ),
      Event(
        id: '3',
        title: 'Research Symposium',
        description: 'Presentations from various research departments',
        startTime: DateTime.now()
            .add(const Duration(days: 1))
            .copyWith(hour: 14, minute: 0),
        endTime: DateTime.now()
            .add(const Duration(days: 1))
            .copyWith(hour: 18, minute: 0),
        location: 'Conference Hall A',
        organizer: 'Research Office',
        type: 'Academic',
        imageUrl: 'https://pathadvisor.ust.hk/static/media/hkust-view.jpg',
      ),
      Event(
        id: '4',
        title: 'Tech Workshop',
        description: 'Hands-on workshop on AI and Machine Learning',
        startTime: DateTime.now()
            .add(const Duration(days: 7))
            .copyWith(hour: 13, minute: 0),
        endTime: DateTime.now()
            .add(const Duration(days: 7))
            .copyWith(hour: 16, minute: 0),
        location: 'Computer Lab 3',
        organizer: 'Computer Science Department',
        type: 'Workshop',
        imageUrl:
            'https://cse.hkust.edu.hk/admin/upload/seminar/20220512-011734.jpg',
      ),
      Event(
        id: '5',
        title: 'Campus Tour',
        description: 'Guided tour of HKUST facilities',
        startTime: DateTime.now().copyWith(hour: 15, minute: 0),
        endTime: DateTime.now().copyWith(hour: 16, minute: 30),
        location: 'Meeting Point: Main Entrance',
        organizer: 'Admissions Office',
        type: 'Tour',
        imageUrl:
            'https://www.ust.hk/sites/default/files/styles/page_content_desktop_x1/public/2022-07/20220706170015.jpg',
      ),
    ];

    // Group events by day for the calendar
    Map<DateTime, List<Event>> eventsByDay = {};
    for (var event in events) {
      final day = DateTime(
          event.startTime.year, event.startTime.month, event.startTime.day);
      if (eventsByDay[day] != null) {
        eventsByDay[day]!.add(event);
      } else {
        eventsByDay[day] = [event];
      }
    }

    setState(() {
      _events = events;
      _eventsByDay = eventsByDay;
      _isLoading = false;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.view_list), text: 'List View'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarView(),
                _buildListView(),
              ],
            ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: DateTime.now().subtract(const Duration(days: 30)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: const CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonShowsNext: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildSelectedDayEvents(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayEvents() {
    final eventsOnSelectedDay = _getEventsForDay(_selectedDay!);

    if (eventsOnSelectedDay.isEmpty) {
      return const Center(
        child: Text(
          'No events on this day',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: eventsOnSelectedDay.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final event = eventsOnSelectedDay[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _events.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return _buildEventCard(_events[index]);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                event.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEventDetailRow(
                    Icons.access_time,
                    '${_formatDateTime(event.startTime)} - ${_formatTime(event.endTime)}'),
                const SizedBox(height: 8),
                _buildEventDetailRow(Icons.location_on, event.location),
                const SizedBox(height: 8),
                _buildEventDetailRow(
                    Icons.people, 'Organized by: ${event.organizer}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle event details or registration
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registered for ${event.title}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getEventTypeColor(event.type),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_getDayName(dateTime.weekday)}, ${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  Color _getEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'orientation':
        return Colors.blue;
      case 'career':
        return Colors.orange;
      case 'academic':
        return Colors.purple;
      case 'workshop':
        return Colors.green;
      case 'tour':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}

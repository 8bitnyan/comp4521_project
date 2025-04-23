class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        startTime: json['start_time'] != null
            ? DateTime.parse(json['start_time'])
            : null,
        endTime:
            json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
        imageUrl: json['image_url'],
      );
}

class Facility {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String buildingCode;
  final String floor;
  final String operatingHours;
  final String contactInfo;
  final double latitude;
  final double longitude;
  final int? currentOccupancy;
  final int? maxOccupancy;
  final List<String> tags;

  Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.buildingCode,
    required this.floor,
    required this.operatingHours,
    required this.contactInfo,
    required this.latitude,
    required this.longitude,
    this.currentOccupancy,
    this.maxOccupancy,
    required this.tags,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      buildingCode: json['building_code'] ?? '',
      floor: json['floor'] ?? '',
      operatingHours: json['operating_hours'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      currentOccupancy: json['current_occupancy'],
      maxOccupancy: json['max_occupancy'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'building_code': buildingCode,
      'floor': floor,
      'operating_hours': operatingHours,
      'contact_info': contactInfo,
      'latitude': latitude,
      'longitude': longitude,
      'current_occupancy': currentOccupancy,
      'max_occupancy': maxOccupancy,
      'tags': tags,
    };
  }

  double get occupancyPercentage {
    if (currentOccupancy == null || maxOccupancy == null || maxOccupancy == 0) {
      return 0.0;
    }
    return (currentOccupancy! / maxOccupancy!) * 100;
  }
}

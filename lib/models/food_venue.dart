class FoodVenue {
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
  final double rating;
  final int numRatings;
  final List<MenuItem> menu;
  final List<String> cuisineTypes;

  FoodVenue({
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
    required this.rating,
    required this.numRatings,
    required this.menu,
    required this.cuisineTypes,
  });

  factory FoodVenue.fromJson(Map<String, dynamic> json) {
    List<MenuItem> menuItems = [];
    if (json['menu'] != null) {
      menuItems = List<MenuItem>.from(
        json['menu'].map((item) => MenuItem.fromJson(item)),
      );
    }

    return FoodVenue(
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
      rating: json['rating']?.toDouble() ?? 0.0,
      numRatings: json['num_ratings'] ?? 0,
      menu: menuItems,
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
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
      'rating': rating,
      'num_ratings': numRatings,
      'menu': menu.map((item) => item.toJson()).toList(),
      'cuisine_types': cuisineTypes,
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final Map<String, dynamic>? nutritionalInfo;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.nutritionalInfo,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      isVegetarian: json['is_vegetarian'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
      nutritionalInfo: json['nutritional_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'nutritional_info': nutritionalInfo,
    };
  }
}

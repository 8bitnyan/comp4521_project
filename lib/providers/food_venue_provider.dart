import 'package:flutter/material.dart';
import '../models/food_venue.dart';
import '../services/food_venue_service.dart';

class FoodVenueProvider with ChangeNotifier {
  final FoodVenueService _foodVenueService = FoodVenueService();

  List<FoodVenue> _venues = [];
  List<FoodVenue> _filteredVenues = [];
  FoodVenue? _selectedVenue;
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  // Getters
  List<FoodVenue> get venues => _venues;
  List<FoodVenue> get filteredVenues => _filteredVenues;
  FoodVenue? get selectedVenue => _selectedVenue;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  // Initialize and load food venues
  Future<void> loadFoodVenues() async {
    _setLoading(true);
    try {
      final venues = await _foodVenueService.getFoodVenues();
      _venues = venues;
      _filteredVenues = List.from(venues);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get food venue by ID
  Future<void> getFoodVenueById(String id) async {
    _setLoading(true);
    try {
      final venue = await _foodVenueService.getFoodVenueById(id);
      _selectedVenue = venue;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Search food venues
  Future<void> searchFoodVenues(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredVenues = List.from(_venues);
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final results = await _foodVenueService.searchFoodVenues(query);
      _filteredVenues = results;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Filter food venues by cuisine type
  void filterByCuisine(String cuisineType) {
    if (cuisineType.isEmpty) {
      _filteredVenues = List.from(_venues);
    } else {
      _filteredVenues = _venues
          .where((venue) => venue.cuisineTypes.contains(cuisineType))
          .toList();
    }
    notifyListeners();
  }

  // Sort venues by rating
  void sortByRating(bool ascending) {
    _filteredVenues.sort((a, b) => ascending
        ? a.rating.compareTo(b.rating)
        : b.rating.compareTo(a.rating));
    notifyListeners();
  }

  // Set selected venue
  void setSelectedVenue(FoodVenue? venue) {
    _selectedVenue = venue;
    notifyListeners();
  }

  // Clear selected venue
  void clearSelectedVenue() {
    _selectedVenue = null;
    notifyListeners();
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

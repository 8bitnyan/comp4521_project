import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../services/facility_service.dart';

class FacilityProvider with ChangeNotifier {
  final FacilityService _facilityService = FacilityService();

  List<Facility> _facilities = [];
  List<Facility> _filteredFacilities = [];
  Facility? _selectedFacility;
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  // Getters
  List<Facility> get facilities => _facilities;
  List<Facility> get filteredFacilities => _filteredFacilities;
  Facility? get selectedFacility => _selectedFacility;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  // Initialize and load facilities
  Future<void> loadFacilities() async {
    _setLoading(true);
    try {
      final facilities = await _facilityService.getFacilities();
      _facilities = facilities;
      _filteredFacilities = List.from(facilities);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get facility by ID
  Future<void> getFacilityById(String id) async {
    _setLoading(true);
    try {
      final facility = await _facilityService.getFacilityById(id);
      _selectedFacility = facility;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Search facilities
  Future<void> searchFacilities(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredFacilities = List.from(_facilities);
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final results = await _facilityService.searchFacilities(query);
      _filteredFacilities = results;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Filter facilities by type/tag
  void filterFacilitiesByTag(String tag) {
    if (tag.isEmpty) {
      _filteredFacilities = List.from(_facilities);
    } else {
      _filteredFacilities = _facilities
          .where((facility) => facility.tags.contains(tag.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Set selected facility
  void setSelectedFacility(Facility? facility) {
    _selectedFacility = facility;
    notifyListeners();
  }

  // Clear selected facility
  void clearSelectedFacility() {
    _selectedFacility = null;
    notifyListeners();
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

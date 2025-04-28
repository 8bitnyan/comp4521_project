import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller for the Google Map
  GoogleMapController? _mapController;

  // Default location (HKUST)
  static const LatLng _defaultLocation = LatLng(22.3373, 114.2636);

  // Map state
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  // Tracking map controller initialization
  Completer<GoogleMapController> _controllerCompleter = Completer();

  // Campus locations to mark on the map
  final List<Map<String, dynamic>> _campusLocations = [
    {
      'id': 'academic_building',
      'position': const LatLng(22.3373, 114.2636),
      'title': 'Academic Building',
      'snippet': 'Main academic complex with lecture halls and laboratories',
    },
    {
      'id': 'library',
      'position': const LatLng(22.3363, 114.2630),
      'title': 'University Library',
      'snippet': 'Five-story building with study spaces and resources',
    },
    {
      'id': 'sports_center',
      'position': const LatLng(22.3380, 114.2619),
      'title': 'Sports Center',
      'snippet': 'Indoor swimming pool, gym, and sports facilities',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Set a timeout to detect map loading failures
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isLoading && !_controllerCompleter.isCompleted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage =
              'Map failed to load. Please check your network connection.';
        });
      }
    });
  }

  void _initializeMap() {
    // Add markers for campus locations
    for (final location in _campusLocations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location['id']),
          position: location['position'],
          infoWindow: InfoWindow(
            title: location['title'],
            snippet: location['snippet'],
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);

      // Change map style if desired
      // _setMapStyle(controller);
    }
  }

  // Future<void> _setMapStyle(GoogleMapController controller) async {
  //   // Customize map style if needed
  //   // String style = await rootBundle.loadString('assets/map_style.json');
  //   // controller.setMapStyle(style);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          // Add help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showMapHelp,
          ),
        ],
      ),
      body: _buildMapContent(),
      floatingActionButton: !_isError
          ? FloatingActionButton(
              onPressed: _centerMap,
              child: const Icon(Icons.center_focus_strong),
            )
          : null,
    );
  }

  Widget _buildMapContent() {
    // If there's an error, show error message
    if (_isError) {
      return _buildErrorView();
    }

    // If running on iOS simulator, show simplified view
    if (Platform.isIOS && !kReleaseMode) {
      return _buildSimplifiedMapView();
    }

    // Otherwise build the actual map with loading indicator
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _defaultLocation,
            zoom: 16.0,
          ),
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _isError = false;
                  _controllerCompleter = Completer();

                  // Try again after a brief delay
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _initializeMap();
                  });

                  // Set another timeout
                  Future.delayed(const Duration(seconds: 8), () {
                    if (mounted &&
                        _isLoading &&
                        !_controllerCompleter.isCompleted) {
                      setState(() {
                        _isLoading = false;
                        _isError = true;
                        _errorMessage =
                            'Map failed to load. Please check your network connection.';
                      });
                    }
                  });
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedMapView() {
    return Stack(
      children: [
        // Background
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Image.asset(
              'assets/images/simplified_map.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image doesn't exist
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text(
                      'HKUST Campus',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Markers
        for (final location in _campusLocations)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 12,
            top: MediaQuery.of(context).size.height * 0.4 - 24,
            child: GestureDetector(
              onTap: () {
                _showLocationInfo(location);
              },
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),

        // Information banner
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: const Text(
              'Simplified map view (Google Maps not available in simulator)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _centerMap() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _defaultLocation,
          zoom: 16.0,
        ),
      ),
    );
  }

  void _showLocationInfo(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(location['title']),
          content: Text(location['snippet']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMapHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Map Help'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                  '• Tap on markers to see information about campus locations'),
              SizedBox(height: 8),
              Text('• Use the button in the bottom right to center the map'),
              SizedBox(height: 8),
              Text('• Pinch to zoom in and out'),
              SizedBox(height: 8),
              Text('• Drag to move the map view'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

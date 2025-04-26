import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/app_config.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Default camera position (can be set to your school's location)
  static const LatLng _defaultLocation =
      LatLng(22.3373, 114.2636); // Example: HKUST

  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    // Example school buildings markers - replace with actual locations
    final List<Map<String, dynamic>> locations = [
      {
        'id': 'academic_building',
        'position': const LatLng(22.3373, 114.2636),
        'title': 'Academic Building',
        'snippet': 'Main academic building with classrooms and labs',
      },
      {
        'id': 'library',
        'position': const LatLng(22.3383, 114.2626),
        'title': 'Library',
        'snippet': 'University Library',
      },
      {
        'id': 'student_center',
        'position': const LatLng(22.3363, 114.2646),
        'title': 'Student Center',
        'snippet': 'Student activities and services',
      },
    ];

    for (final location in locations) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 16.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: _defaultLocation,
                zoom: 16.0,
              ),
            ),
          );
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

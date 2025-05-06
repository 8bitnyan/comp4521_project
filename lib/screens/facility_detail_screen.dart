import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/facility.dart';

class FacilityDetailScreen extends StatefulWidget {
  final Facility facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize marker for the facility
    _markers.add(
      Marker(
        markerId: MarkerId(widget.facility.id),
        position: LatLng(widget.facility.latitude, widget.facility.longitude),
        infoWindow: InfoWindow(
          title: widget.facility.name,
          snippet: '${widget.facility.buildingCode}, ${widget.facility.floor}',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.facility.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Hero(
                tag: 'facility-image-${widget.facility.id}',
                child: Image.network(
                  widget.facility.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.error, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: loc.details),
                    Tab(text: loc.map),
                    Tab(text: loc.hours),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                ),
                SizedBox(
                  height: 500, // Fixed height for the tab content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(loc),
                      _buildMapTab(),
                      _buildHoursTab(loc),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add navigation logic here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.navigation_started),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.directions),
        label: Text(loc.navigate),
      ),
    );
  }

  Widget _buildDetailsTab(AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.facility.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            loc.location,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.facility.buildingCode}, ${widget.facility.floor}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            loc.contact,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.facility.contactInfo,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.facility.currentOccupancy != null &&
              widget.facility.maxOccupancy != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.current_occupancy,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.facility.currentOccupancy}/${widget.facility.maxOccupancy}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${widget.facility.occupancyPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _getOccupancyColor(
                            widget.facility.occupancyPercentage),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.facility.occupancyPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getOccupancyColor(widget.facility.occupancyPercentage),
                  ),
                  minHeight: 10,
                ),
                const SizedBox(height: 16),
              ],
            ),
          Text(
            loc.tags,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.facility.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Colors.blue[50],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    final lat = widget.facility.latitude;
    final lng = widget.facility.longitude;
    print('Building MapTab: lat=$lat, lng=$lng');
    if (lat == null || lng == null || lat.isNaN || lng.isNaN) {
      print('Invalid coordinates for map');
      return Center(child: Text('Location not available'));
    }
    print('Rendering GoogleMap widget');
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 17.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  Widget _buildHoursTab(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.operating_hours,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.facility.operatingHours,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // Here you could parse the hours string and display it in a more structured way
                  // For example, splitting by commas and displaying each part on a new line
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.notes,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.hours_may_vary,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getOccupancyColor(double percentage) {
    if (percentage < 50) {
      return Colors.green;
    } else if (percentage < 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

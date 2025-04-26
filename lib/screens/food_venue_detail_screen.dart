import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/food_venue.dart';

class FoodVenueDetailScreen extends StatefulWidget {
  final FoodVenue venue;

  const FoodVenueDetailScreen({super.key, required this.venue});

  @override
  State<FoodVenueDetailScreen> createState() => _FoodVenueDetailScreenState();
}

class _FoodVenueDetailScreenState extends State<FoodVenueDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize marker for the venue
    _markers.add(
      Marker(
        markerId: MarkerId(widget.venue.id),
        position: LatLng(widget.venue.latitude, widget.venue.longitude),
        infoWindow: InfoWindow(
          title: widget.venue.name,
          snippet: '${widget.venue.buildingCode}, ${widget.venue.floor}',
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.venue.name,
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
                tag: 'venue-image-${widget.venue.id}',
                child: Image.network(
                  widget.venue.imageUrl,
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildRatingIndicator(widget.venue.rating),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.venue.rating.toStringAsFixed(1)} (${widget.venue.numRatings} reviews)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Menu'),
                    Tab(text: 'Info'),
                    Tab(text: 'Map'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                ),
                SizedBox(
                  height: 500, // Fixed height for the tab content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMenuTab(),
                      _buildInfoTab(),
                      _buildMapTab(),
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
            const SnackBar(
              content: Text('Navigation started'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.directions),
        label: const Text('Navigate'),
      ),
    );
  }

  Widget _buildRatingIndicator(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildMenuTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.venue.menu.length,
      itemBuilder: (context, index) {
        final menuItem = widget.venue.menu[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    menuItem.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              menuItem.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '\$${menuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menuItem.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (menuItem.isVegetarian)
                            _buildDietaryTag('Vegetarian', Colors.green),
                          if (menuItem.isVegan)
                            _buildDietaryTag('Vegan', Colors.lightGreen),
                          if (menuItem.isGlutenFree)
                            _buildDietaryTag('Gluten-free', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDietaryTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.venue.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Location',
            style: TextStyle(
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
                  '${widget.venue.buildingCode}, ${widget.venue.floor}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.venue.operatingHours,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.venue.contactInfo,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cuisine Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.venue.cuisineTypes.map((cuisine) {
              return Chip(
                label: Text(cuisine),
                backgroundColor: Colors.orange[50],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.venue.latitude, widget.venue.longitude),
        zoom: 17.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }
}

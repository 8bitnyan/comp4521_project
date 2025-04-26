import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_venue_provider.dart';
import '../models/food_venue.dart';
import '../widgets/food_venue_card.dart';

class FoodVenuesScreen extends StatefulWidget {
  const FoodVenuesScreen({super.key});

  @override
  State<FoodVenuesScreen> createState() => _FoodVenuesScreenState();
}

class _FoodVenuesScreenState extends State<FoodVenuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _cuisineFilters = [
    'All',
    'Asian',
    'Western',
    'Fast Food',
    'Coffee',
    'Bakery',
  ];
  String _selectedCuisine = 'All';
  bool _sortByHighestRating = true;

  @override
  void initState() {
    super.initState();
    // Load food venues when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodVenueProvider>(context, listen: false).loadFoodVenues();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final foodVenueProvider =
        Provider.of<FoodVenueProvider>(context, listen: false);
    foodVenueProvider.searchFoodVenues(query);
  }

  void _filterByCuisine(String cuisine) {
    setState(() {
      _selectedCuisine = cuisine;
    });

    final foodVenueProvider =
        Provider.of<FoodVenueProvider>(context, listen: false);
    if (cuisine == 'All') {
      foodVenueProvider.filterByCuisine('');
    } else {
      foodVenueProvider.filterByCuisine(cuisine);
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _sortByHighestRating = !_sortByHighestRating;
    });

    final foodVenueProvider =
        Provider.of<FoodVenueProvider>(context, listen: false);
    foodVenueProvider.sortByRating(!_sortByHighestRating);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Venues'),
        actions: [
          IconButton(
            icon: Icon(_sortByHighestRating
                ? Icons.arrow_downward
                : Icons.arrow_upward),
            onPressed: _toggleSortOrder,
            tooltip: _sortByHighestRating
                ? 'Sort by highest rating'
                : 'Sort by lowest rating',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search food venues...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    ),
                  ),
                  onChanged: _performSearch,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cuisineFilters.map((cuisine) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(cuisine),
                          selected: _selectedCuisine == cuisine,
                          onSelected: (selected) {
                            if (selected) {
                              _filterByCuisine(cuisine);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<FoodVenueProvider>(
              builder: (context, foodVenueProvider, child) {
                if (foodVenueProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (foodVenueProvider.error.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Error: ${foodVenueProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final venues = foodVenueProvider.filteredVenues;

                if (venues.isEmpty) {
                  return const Center(
                    child: Text(
                      'No food venues found',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    return FoodVenueCard(venue: venue);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

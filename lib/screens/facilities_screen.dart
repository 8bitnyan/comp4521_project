import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/facility_provider.dart';
import '../widgets/facility_card.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterTags = [
    'All',
    'Library',
    'Sports',
    'Academic',
    'Student',
    'Food',
  ];
  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    // Load facilities when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FacilityProvider>(context, listen: false).loadFacilities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final facilityProvider =
        Provider.of<FacilityProvider>(context, listen: false);
    facilityProvider.searchFacilities(query);
  }

  void _filterByTag(String tag) {
    setState(() {
      _selectedTag = tag;
    });

    final facilityProvider =
        Provider.of<FacilityProvider>(context, listen: false);
    if (tag == 'All') {
      facilityProvider.filterFacilitiesByTag('');
    } else {
      facilityProvider.filterFacilitiesByTag(tag.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localizedTags = [
      loc.all,
      loc.library,
      loc.sports,
      loc.academic,
      loc.student,
      loc.food,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.campus_facilities),
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
                    hintText: loc.search_facilities,
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
                    children: List.generate(localizedTags.length, (i) {
                      final tag = _filterTags[i];
                      final localizedTag = localizedTags[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(localizedTag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            if (selected) {
                              _filterByTag(tag);
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<FacilityProvider>(
              builder: (context, facilityProvider, child) {
                if (facilityProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (facilityProvider.error.isNotEmpty) {
                  return Center(
                    child: Text(
                      loc.error(facilityProvider.error),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final facilities = facilityProvider.filteredFacilities;

                if (facilities.isEmpty) {
                  return Center(
                    child: Text(
                      loc.no_facilities_found,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: facilities.length,
                  itemBuilder: (context, index) {
                    final facility = facilities[index];
                    return FacilityCard(facility: facility);
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

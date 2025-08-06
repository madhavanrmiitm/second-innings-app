// caregivers_view.dart (for Family)
import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/caregiver_details_view.dart';
import 'package:second_innings/dashboard/family/views/view_current_hired_caregiver_view.dart';
import 'package:second_innings/dashboard/family/views/caregiver_requests_view.dart';
import 'package:second_innings/widgets/feature_card.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/care_service.dart';

class CaregiversView extends StatefulWidget {
  const CaregiversView({super.key});

  @override
  State<CaregiversView> createState() => _CaregiversViewState();
}

class _CaregiversViewState extends State<CaregiversView> {
  final List<String> _filters = [
    'Madras',
    'Physiotherapy',
    'Memory Related',
    'Full Day',
    'Half Day',
  ];
  final Set<String> _selectedFilters = {'Madras'};

  List<Map<String, dynamic>> _caregivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCaregivers();
  }

  Future<void> _loadCaregivers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await CareService.getCaregivers();

      if (response.statusCode == 200) {
        final caregiversData = response.data?['data']?['caregivers'] as List?;
        if (caregiversData != null) {
          setState(() {
            _caregivers = caregiversData.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _caregivers = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load caregivers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading caregivers: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: '2nd Innings'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(colorScheme),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FeatureCard(
                          title: "Current",
                          isColumn: true,
                          icon: Icons.person_search_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ViewCurrentHiredCaregiverPage(),
                              ),
                            );
                          },
                          colorScheme: colorScheme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FeatureCard(
                          title: "Requests",
                          isColumn: true,
                          icon: Icons.request_page_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CaregiverRequestsPage(),
                              ),
                            );
                          },
                          colorScheme: colorScheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(colorScheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!, style: textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCaregivers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildCaregiverList(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search based on needs',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colorScheme.primaryContainer.withAlpha(51),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilters.contains(filter);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters.add(filter);
                  } else {
                    _selectedFilters.remove(filter);
                  }
                });
              },
              selectedColor: colorScheme.primaryContainer.withAlpha(102),
              checkmarkColor: colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCaregiverList(ColorScheme colorScheme, TextTheme textTheme) {
    return SliverList.builder(
      itemCount: _caregivers.length,
      itemBuilder: (context, index) {
        final caregiver = _caregivers[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: colorScheme.primaryContainer.withAlpha(51),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              hoverColor: colorScheme.primaryContainer.withAlpha(100),
              splashColor: colorScheme.primary.withAlpha(80),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CaregiverDetailsView(
                      name: caregiver['full_name'] ?? 'Unknown',
                      age: '${caregiver['age'] ?? 'N/A'} yrs',
                      gender: caregiver['gender'] ?? 'N/A',
                      desc:
                          caregiver['description'] ??
                          'No description available',
                      tags: _parseTags(caregiver['tags']),
                      caregiverId: caregiver['id'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caregiver['name']?.toString() ?? 'Unknown',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${caregiver['age']?.toString() ?? 'N/A'} . ${caregiver['gender']?.toString() ?? 'N/A'}',
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      caregiver['desc']?.toString() ??
                          'No description available',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: _parseTags(caregiver['tags'])
                          .map<Widget>(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: colorScheme.surface.withAlpha(
                                128,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Parse tags - handle both string and list formats
  List<String> _parseTags(dynamic tagsData) {
    List<String> tags = [];
    if (tagsData != null) {
      if (tagsData is String) {
        // Parse comma-separated string
        tags = tagsData.split(',').map((tag) => tag.trim()).toList();
      } else if (tagsData is List) {
        // Already a list
        tags = tagsData.cast<String>();
      }
    }
    return tags;
  }
}

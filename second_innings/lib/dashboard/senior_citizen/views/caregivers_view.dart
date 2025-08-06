import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/caregiver_details_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/caregiver_requests_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/view_current_hired_caregiver_view.dart';
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

    return CustomScrollView(
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
                _buildFilterChips(context, colorScheme),
                const SizedBox(height: 16),
                _buildNavigationButtons(context, colorScheme),
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
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
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
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search based on needs',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, ColorScheme colorScheme) {
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
              selectedColor: colorScheme.primaryContainer.withValues(
                alpha: 0.4,
              ),
              checkmarkColor: colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: FeatureCard(
            title: 'Requests',
            icon: Icons.request_page_outlined,
            isColumn: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CaregiverRequestsView(),
                ),
              );
            },
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FeatureCard(
            title: 'Hired Caregiver',
            icon: Icons.person_pin_outlined,
            isColumn: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewCurrentHiredCaregiverView(),
                ),
              );
            },
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildCaregiverList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_caregivers.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No caregivers available',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for available caregivers',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: _caregivers.length,
      itemBuilder: (context, index) {
        final caregiver = _caregivers[index];

        // Parse tags - handle both string and list formats
        List<String> tags = [];
        final tagsData = caregiver['tags'];
        if (tagsData != null) {
          if (tagsData is String) {
            // Parse comma-separated string
            tags = tagsData.split(',').map((tag) => tag.trim()).toList();
          } else if (tagsData is List) {
            // Already a list
            tags = tagsData.cast<String>();
          }
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaregiverDetailsView(
                  name: caregiver['full_name'] ?? 'Unknown',
                  age: '${caregiver['age'] ?? 'N/A'} yrs',
                  gender: caregiver['gender'] ?? 'N/A',
                  desc: caregiver['description'] ?? 'No description available',
                  tags: tags,
                ),
              ),
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.primaryContainer.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caregiver['full_name'] ?? 'Unknown',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${caregiver['age'] ?? 'N/A'} yrs . ${caregiver['gender'] ?? 'N/A'}',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    caregiver['description'] ?? 'No description available',
                    style: textTheme.bodyMedium,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: colorScheme.surface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

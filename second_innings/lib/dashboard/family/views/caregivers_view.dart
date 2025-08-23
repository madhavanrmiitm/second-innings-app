// caregivers_view.dart (for Family)
import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/caregiver_details_view.dart';
import 'package:second_innings/dashboard/family/views/view_current_hired_caregiver_view.dart';
import 'package:second_innings/dashboard/family/views/caregiver_requests_view.dart';
import 'package:second_innings/widgets/feature_card.dart';

import 'package:second_innings/services/care_service.dart';
import 'package:second_innings/services/family_service.dart';

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
  List<Map<String, dynamic>> _linkedSeniorCitizens = [];
  Map<String, dynamic>? _selectedSeniorCitizen;
  bool _isLoading = true;
  bool _isLoadingSeniorCitizens = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLinkedSeniorCitizens();
  }

  Future<void> _loadLinkedSeniorCitizens() async {
    setState(() {
      _isLoadingSeniorCitizens = true;
    });

    try {
      final response = await FamilyService.getLinkedSeniorCitizens();

      if (response.statusCode == 200) {
        final seniorCitizensData =
            response.data?['data']?['linked_senior_citizens'] as List?;
        if (seniorCitizensData != null && seniorCitizensData.isNotEmpty) {
          setState(() {
            _linkedSeniorCitizens = seniorCitizensData
                .cast<Map<String, dynamic>>();
            _selectedSeniorCitizen = _linkedSeniorCitizens.first;
            _isLoadingSeniorCitizens = false;
          });
          // Load caregivers for the first senior citizen
          _loadCaregivers();
        } else {
          setState(() {
            _linkedSeniorCitizens = [];
            _selectedSeniorCitizen = null;
            _isLoadingSeniorCitizens = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load linked senior citizens';
          _isLoadingSeniorCitizens = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading linked senior citizens: $e';
        _isLoadingSeniorCitizens = false;
      });
    }
  }

  Future<void> _loadCaregivers() async {
    if (_selectedSeniorCitizen == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await CareService.getCaregiversForSeniorCitizen(
        seniorCitizenId: _selectedSeniorCitizen!['id'],
      );

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

  Future<void> _refreshCaregivers() async {
    await _loadCaregivers();
  }

  void _onSeniorCitizenChanged(Map<String, dynamic>? seniorCitizen) {
    setState(() {
      _selectedSeniorCitizen = seniorCitizen;
    });
    if (seniorCitizen != null) {
      _loadCaregivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshCaregivers,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: const Text('2nd Innings'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshCaregivers,
                  tooltip: 'Refresh Caregivers',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSeniorCitizenSelector(colorScheme, textTheme),
                    const SizedBox(height: 16),
                    if (_selectedSeniorCitizen != null) ...[
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
                                        ViewCurrentHiredCaregiverPage(
                                          seniorCitizenId:
                                              _selectedSeniorCitizen!['id'],
                                          seniorCitizenData:
                                              _selectedSeniorCitizen!,
                                        ),
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
                              icon: Icons.assignment_outlined,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CaregiverRequestsPage(
                                      seniorCitizenId:
                                          _selectedSeniorCitizen!['id'],
                                      seniorCitizenData:
                                          _selectedSeniorCitizen!,
                                    ),
                                  ),
                                );
                              },
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Available Caregivers",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFilterChips(colorScheme),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            if (_isLoadingSeniorCitizens)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_linkedSeniorCitizens.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No linked senior citizens',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Link a senior citizen to view and hire caregivers',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_isLoading)
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: _buildCaregiversList(colorScheme, textTheme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeniorCitizenSelector(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (_linkedSeniorCitizens.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Senior Citizen',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedSeniorCitizen,
              isExpanded: true,
              hint: Text(
                'Choose a senior citizen',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              items: _linkedSeniorCitizens.map((seniorCitizen) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: seniorCitizen,
                  child: Text(
                    seniorCitizen['full_name'] ?? 'Unknown',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onSeniorCitizenChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search caregivers...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.map((filter) {
        final isSelected = _selectedFilters.contains(filter);
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFilters.add(filter);
              } else {
                _selectedFilters.remove(filter);
              }
            });
          },
          backgroundColor: colorScheme.surfaceContainerHighest,
          selectedColor: colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCaregiversList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_caregivers.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No caregivers found',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or search terms',
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
        final name = caregiver['full_name'] ?? 'Unknown';
        final specialization = caregiver['specialization'] ?? 'General Care';
        final experience = caregiver['experience_years'] ?? 0;
        final rating = caregiver['rating'] ?? 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaregiverDetailsView(
                  caregiver: caregiver,
                  seniorCitizenId: _selectedSeniorCitizen!['id'],
                  seniorCitizenData: _selectedSeniorCitizen!,
                ),
              ),
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.primaryContainer.withAlpha(51),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer.withAlpha(
                      204,
                    ),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        specialization,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.work,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$experience years',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(128),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

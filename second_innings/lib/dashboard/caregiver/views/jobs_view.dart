import 'package:flutter/material.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/user_service.dart';

class JobsView extends StatefulWidget {
  const JobsView({super.key});

  @override
  State<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> {
  final List<String> _filters = [
    'Madras',
    'Physiotherapy',
    'Memory Related',
    'Full Day',
    'Half Day',
  ];
  final Set<String> _selectedFilters = {'Madras'};

  bool _isLoading = true;
  bool _isPendingApproval = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userData = await UserService.getUserData();
      if (userData != null) {
        final status = userData['status']?.toString().toLowerCase();
        setState(() {
          _isPendingApproval = status == 'pending_approval';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to load user data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error checking user status: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const CustomScrollView(
        slivers: [
          UserAppBar(title: '2nd Innings'),
          SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    if (_error != null) {
      return CustomScrollView(
        slivers: [
          const UserAppBar(title: '2nd Innings'),
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkUserStatus,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_isPendingApproval) {
      return CustomScrollView(
        slivers: [
          const UserAppBar(title: '2nd Innings'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.error, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 80,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Profile Under Review',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your caregiver profile has been sent for admin review. You\'ll be able to access job listings once your profile is approved.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Icon(
                          Icons.access_time,
                          size: 40,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Waiting for approval...',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _checkUserStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Original job listing view for approved caregivers
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildJobList(colorScheme, textTheme),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search based on interests',
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

  Widget _buildJobList(ColorScheme colorScheme, TextTheme textTheme) {
    final jobs = [
      {
        'name': 'Ram Kumar',
        'age': '65 yrs',
        'gender': 'Male',
        'desc':
            'Take him for daily checkups everyday. Physiotherapist will come, get him ready for that. Give water periodically. 10 AM to 6 PM',
        'tags': ['Physio', 'Car Drives', 'Checkups'],
      },
      {
        'name': 'Amrita',
        'age': '70 yrs',
        'gender': 'Female',
        'desc':
            'Take her for daily checkups everyday. Take care of her everyday. 11 AM to 3 PM',
        'tags': ['Half Day', 'Checkups'],
      },
    ];

    return SliverList.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
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
                  '${job['name']}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${job['age']} . ${job['gender']}',
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Text(job['desc'].toString(), style: textTheme.bodyMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  children: (job['tags'] as List<String>)
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
            ),
          ),
        );
      },
    );
  }
}

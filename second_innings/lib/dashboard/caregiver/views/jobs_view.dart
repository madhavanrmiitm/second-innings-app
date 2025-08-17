import 'package:flutter/material.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/user_service.dart';
import 'package:second_innings/services/care_service.dart';

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
  List<Map<String, dynamic>> _careRequests = [];

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

        if (!_isPendingApproval) {
          _loadCareRequests();
        }
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

  Future<void> _loadCareRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await CareService.getCareRequests();

      if (response.statusCode == 200) {
        final requestsData = response.data?['data']?['care_requests'] as List?;
        if (requestsData != null) {
          setState(() {
            _careRequests = requestsData.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _careRequests = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load care requests';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading care requests: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _applyForRequest(String requestId) async {
    try {
      final response = await CareService.applyForRequest(requestId: requestId);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully')),
        );
        // Reload requests to reflect the change
        await _loadCareRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to apply for request'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error applying for request: $e')));
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

    // Job listing view for approved caregivers
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
    if (_careRequests.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.work_outline, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No care requests available',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new opportunities',
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
      itemCount: _careRequests.length,
      itemBuilder: (context, index) {
        final request = _careRequests[index];
        final status = request['status'] ?? 'pending';
        final isPending = status == 'pending';

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request['title'] ?? 'Untitled Request',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? colorScheme.primary
                            : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          color: isPending
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  request['description'] ?? 'No description available',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (request['location'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request['location'],
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (request['timing'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request['timing'],
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (isPending)
                  ElevatedButton(
                    onPressed: () => _applyForRequest(request['id'].toString()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Apply for this job'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
  bool _isLoading = true;
  bool _isPendingApproval = false;
  String? _error;
  List<Map<String, dynamic>> _careRequests = [];
  List<Map<String, dynamic>> _filteredCareRequests = [];
  String _searchQuery = '';

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
            _filteredCareRequests = List.from(_careRequests);
            _isLoading = false;
          });
        } else {
          setState(() {
            _careRequests = [];
            _filteredCareRequests = [];
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredCareRequests = List.from(_careRequests);
      });
      return;
    }

    final filtered = _careRequests.where((group) {
      final seniorCitizenName = (group['senior_citizen_name'] ?? '')
          .toString()
          .toLowerCase();
      final requesterName =
          (group['requests'] as List?)?.any((request) {
            final requester = (request['requester_name'] ?? '')
                .toString()
                .toLowerCase();
            return requester.contains(_searchQuery.toLowerCase());
          }) ??
          false;

      return seniorCitizenName.contains(_searchQuery.toLowerCase()) ||
          requesterName;
    }).toList();

    setState(() {
      _filteredCareRequests = filtered;
    });
  }

  Future<void> _applyForRequest(String requestId) async {
    try {
      final response = await CareService.applyForRequest(requestId: requestId);

      if (!mounted) return;

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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error applying for request: $e')));
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
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
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by senior citizen or requester name...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 20),
              onPressed: () => _onSearchChanged(''),
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  Widget _buildJobList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_filteredCareRequests.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  _searchQuery.isNotEmpty
                      ? Icons.search_off
                      : Icons.work_outline,
                  size: 64,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No matching requests found'
                      : 'No care requests available',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try adjusting your search terms'
                      : 'Check back later for new opportunities',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: _filteredCareRequests.length,
      itemBuilder: (context, index) {
        final group = _filteredCareRequests[index];
        final seniorCitizenName = group['senior_citizen_name'] ?? 'Unknown';
        final requests = group['requests'] as List? ?? [];

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
                // Senior Citizen Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer.withAlpha(
                        204,
                      ),
                      child: Text(
                        seniorCitizenName.isNotEmpty
                            ? seniorCitizenName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seniorCitizenName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${requests.length} request${requests.length == 1 ? '' : 's'}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Individual Requests
                ...requests.map((request) {
                  final status = request['status'] ?? 'pending';
                  final isPending = status == 'pending';
                  final location =
                      request['location'] ?? 'Location not specified';
                  final timing =
                      request['timing_to_visit'] ?? 'Timing not specified';
                  final requesterName = request['requester_name'] ?? 'Unknown';
                  final createdAt = request['created_at'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Request #${request['id']}',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  status,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Requested by: $requesterName',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Visit: ${_formatDateTime(timing)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Posted: ${_formatDateTime(createdAt)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        if (isPending) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _applyForRequest(request['id'].toString()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Apply for this job'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

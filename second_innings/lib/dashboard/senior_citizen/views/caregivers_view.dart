import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/caregiver_details_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/caregiver_requests_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/view_current_hired_caregiver_view.dart';
import 'package:second_innings/widgets/feature_card.dart';
import 'package:second_innings/services/care_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _filteredCaregivers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCaregivers();
    _loadCaregiverRequests();
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
            _filteredCaregivers = List.from(_caregivers);
            _isLoading = false;
          });
          _buildDynamicFilters();
        } else {
          setState(() {
            _caregivers = [];
            _filteredCaregivers = [];
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

  void _buildDynamicFilters() {
    final Set<String> dynamicFilters = <String>{};

    for (final caregiver in _caregivers) {
      // Add location-based filters (if available)
      if (caregiver['location'] != null &&
          caregiver['location'].toString().isNotEmpty) {
        dynamicFilters.add(caregiver['location'].toString());
      }

      // Add tags as filters
      final tags = _parseTags(caregiver['tags']);
      for (final tag in tags) {
        if (tag.isNotEmpty) {
          dynamicFilters.add(tag);
        }
      }

      // Add specialization-based filters (if available)
      if (caregiver['specialization'] != null &&
          caregiver['specialization'].toString().isNotEmpty) {
        dynamicFilters.add(caregiver['specialization'].toString());
      }
    }

    // Convert to list and sort alphabetically
    final sortedFilters = dynamicFilters.toList()..sort();

    setState(() {
      _filters.clear();
      _filters.addAll(sortedFilters);
      _selectedFilters.clear();
      if (_filters.isNotEmpty) {
        _selectedFilters.add(_filters.first);
      }
    });
  }

  void _applyFiltersAndSearch() {
    List<Map<String, dynamic>> filtered = List.from(_caregivers);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((caregiver) {
        final name = (caregiver['full_name'] ?? '').toString().toLowerCase();
        final description = (caregiver['description'] ?? '')
            .toString()
            .toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply tag filters
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((caregiver) {
        final tags = _parseTags(caregiver['tags']);
        final location = (caregiver['location'] ?? '').toString();
        final specialization = (caregiver['specialization'] ?? '').toString();

        // Check if any selected filter matches tags, location, or specialization
        for (final filter in _selectedFilters) {
          if (tags.contains(filter) ||
              location.toLowerCase() == filter.toLowerCase() ||
              specialization.toLowerCase() == filter.toLowerCase()) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    setState(() {
      _filteredCaregivers = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }

  void _onFilterChanged(String filter, bool selected) {
    setState(() {
      if (selected) {
        _selectedFilters.add(filter);
      } else {
        _selectedFilters.remove(filter);
      }
    });
    _applyFiltersAndSearch();
  }

  Future<void> _loadCaregiverRequests() async {
    try {
      final response = await CareService.getCaregiverRequests();

      if (response.statusCode == 200) {
        final requestsData = response.data?['data'];
        if (requestsData != null) {
          final sentRequests = requestsData['sent_requests'] as List?;
          setState(() {
            _sentRequests = sentRequests?.cast<Map<String, dynamic>>() ?? [];
          });
        } else {
          setState(() {
            _sentRequests = [];
          });
        }
      } else {
        // Silently handle error for requests as it's not critical
        // Could log to a proper logging service in production
      }
    } catch (e) {
      // Silently handle error for requests as it's not critical
      // Could log to a proper logging service in production
    }
  }

  Future<void> _refreshRequests() async {
    await _loadCaregiverRequests();
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadCaregivers(), _loadCaregiverRequests()]);
  }

  bool _hasSentRequest(int caregiverId) {
    return _sentRequests.any(
      (request) => request['caregiver_id'] == caregiverId,
    );
  }

  Map<String, dynamic>? _getLatestRequest(int caregiverId) {
    try {
      final requests = _sentRequests
          .where((request) => request['caregiver_id'] == caregiverId)
          .toList();

      if (requests.isEmpty) return null;

      // Sort by created_at to get the latest request
      requests.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
        return dateB.compareTo(dateA); // Latest first
      });

      return requests.first;
    } catch (e) {
      return null;
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: const Text('2nd Innings'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshAll,
                  tooltip: 'Refresh All',
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
                sliver: _buildCaregiversList(context, colorScheme, textTheme),
              ),
          ],
        ),
      ),
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
                hintText: 'Search by name or description...',
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

  Widget _buildFilterChips(BuildContext context, ColorScheme colorScheme) {
    if (_filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filters.map((filter) {
            final isSelected = _selectedFilters.contains(filter);
            return FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _onFilterChanged(filter, selected),
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(
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
                  builder: (context) => const ViewCurrentHiredCaregiverView(),
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
                  builder: (context) => const CaregiverRequestsView(),
                ),
              );
            },
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildCaregiversList(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (_filteredCaregivers.isEmpty) {
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
      itemCount: _filteredCaregivers.length,
      itemBuilder: (context, index) {
        final caregiver = _filteredCaregivers[index];
        final name = caregiver['full_name'] ?? 'Unknown';
        final description =
            caregiver['description'] ?? 'No description available';
        final tags = _parseTags(caregiver['tags']);
        final youtubeUrl = caregiver['youtube_url'];
        final hasSentRequest = _hasSentRequest(caregiver['id']);
        final latestRequest = _getLatestRequest(caregiver['id']);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CaregiverDetailsView(caregiver: caregiver),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colorScheme.primaryContainer.withAlpha(
                          204,
                        ),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasSentRequest && latestRequest != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    latestRequest['status'],
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      latestRequest['status'],
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(latestRequest['status']),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _getStatusColor(
                                      latestRequest['status'],
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (hasSentRequest && latestRequest != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Show request details or allow cancellation
                              _showRequestDetails(
                                context,
                                latestRequest,
                                caregiver,
                              );
                            },
                            icon: Icon(Icons.info_outline, size: 16),
                            label: Text('View Request'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showRequestCaregiverDialog(context, caregiver);
                            },
                            icon: Icon(Icons.person_add, size: 16),
                            label: Text('Request Caregiver'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                      if (youtubeUrl != null && youtubeUrl.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () async {
                            // Handle YouTube video opening
                            await _openYouTubeVideo(youtubeUrl);
                          },
                          icon: Icon(Icons.play_circle_outline),
                          tooltip: 'Watch Introduction Video',
                          style: IconButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRequestDetails(
    BuildContext context,
    Map<String, dynamic> request,
    Map<String, dynamic> caregiver,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Caregiver: ${caregiver['full_name']}'),
            Text('Status: ${_getStatusText(request['status'])}'),
            Text('Requested: ${_formatDate(request['created_at'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (request['status'] == 'pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelRequest(request['id']);
              },
              child: Text('Cancel Request'),
            ),
          ],
        ],
      ),
    );
  }

  void _showRequestCaregiverDialog(
    BuildContext context,
    Map<String, dynamic> caregiver,
  ) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request ${caregiver['full_name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Would you like to send a request to ${caregiver['full_name']}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Message (optional)',
                border: OutlineInputBorder(),
                hintText: 'Add a personal message...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendCaregiverRequest(caregiver['id'], messageController.text);
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendCaregiverRequest(int caregiverId, String message) async {
    try {
      final response = await CareService.requestCaregiver(
        caregiverId: caregiverId,
        message: message.isNotEmpty ? message : null,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request sent successfully!')));
        await _refreshRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to send request')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending request: $e')));
    }
  }

  Future<void> _cancelRequest(int requestId) async {
    try {
      final response = await CareService.closeCaregiverRequest(
        requestId: requestId,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request closed successfully!')));
        await _refreshRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to close request')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error closing request: $e')));
    }
  }

  Future<void> _openYouTubeVideo(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open video URL')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening video: $e')));
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) {
      return tags.map((tag) => tag.toString()).toList();
    }
    if (tags is String) {
      return tags.split(',').map((tag) => tag.trim()).toList();
    }
    return [];
  }
}

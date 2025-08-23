import 'package:flutter/material.dart';
import 'package:second_innings/services/care_service.dart';

class CaregiverRequestsPage extends StatefulWidget {
  final int seniorCitizenId;
  final Map<String, dynamic> seniorCitizenData;

  const CaregiverRequestsPage({
    super.key,
    required this.seniorCitizenId,
    required this.seniorCitizenData,
  });

  @override
  State<CaregiverRequestsPage> createState() => _CaregiverRequestsPageState();
}

class _CaregiverRequestsPageState extends State<CaregiverRequestsPage> {
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _receivedRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCaregiverRequests();
  }

  Future<void> _loadCaregiverRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await CareService.getCaregiverRequestsForSeniorCitizen(
        seniorCitizenId: widget.seniorCitizenId,
      );

      if (response.statusCode == 200) {
        final sentRequestsData =
            response.data?['data']?['sent_requests'] as List?;
        final receivedRequestsData =
            response.data?['data']?['received_requests'] as List?;

        setState(() {
          _sentRequests = sentRequestsData?.cast<Map<String, dynamic>>() ?? [];
          _receivedRequests =
              receivedRequestsData?.cast<Map<String, dynamic>>() ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load caregiver requests';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading caregiver requests: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    try {
      final response = await CareService.acceptCaregiverRequest(
        requestId: requestId,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted successfully')),
        );
        _loadCaregiverRequests(); // Reload data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to accept request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accepting request: $e')));
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      final response = await CareService.rejectCaregiverRequest(
        requestId: requestId,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected successfully')),
        );
        _loadCaregiverRequests(); // Reload data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to reject request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error rejecting request: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver Requests',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'For: ${widget.seniorCitizenData['full_name'] ?? 'Unknown'}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
                      onPressed: _loadCaregiverRequests,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildSectionHeader(context, 'Received Requests'),
            _buildReceivedRequestsList(
              context,
              colorScheme,
              textTheme,
              _receivedRequests,
            ),
            _buildSectionHeader(context, 'Sent Requests'),
            _buildSentRequestsList(
              context,
              colorScheme,
              textTheme,
              _sentRequests,
            ),
          ],
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverList _buildReceivedRequestsList(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<Map<String, dynamic>> requests,
  ) {
    return SliverList.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
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
                  backgroundColor: colorScheme.primaryContainer.withAlpha(204),
                  child: Text(
                    (request['caregiver_name'] ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['caregiver_name'] ?? 'Unknown',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Status: ${request['status'] ?? 'Unknown'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        _rejectRequest(request['id']);
                      },
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _acceptRequest(request['id']);
                      },
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverList _buildSentRequestsList(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<Map<String, dynamic>> requests,
  ) {
    return SliverList.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
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
                  backgroundColor: colorScheme.primaryContainer.withAlpha(204),
                  child: Text(
                    (request['caregiver_name'] ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['caregiver_name'] ?? 'Unknown',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Status: ${request['status'] ?? 'Unknown'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement withdraw functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Withdraw functionality not implemented yet',
                        ),
                      ),
                    );
                  },
                  child: const Text('Withdraw'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

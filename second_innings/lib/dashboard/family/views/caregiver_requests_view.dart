import 'package:flutter/material.dart';

class CaregiverRequestsPage extends StatelessWidget {
  const CaregiverRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Sample data for sent and received requests
    final sentRequests = [
      {'name': 'Ashwin', 'status': 'Pending'},
      {'name': 'Priya', 'status': 'Pending'},
    ];

    final receivedRequests = [
      {'name': 'Madhavan', 'status': 'Awaiting your response'},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
            title: Text(
              'Caregiver Requests',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          _buildSectionHeader(context, 'Received Requests'),
          _buildReceivedRequestsList(
            context,
            colorScheme,
            textTheme,
            receivedRequests,
          ),
          _buildSectionHeader(context, 'Sent Requests'),
          _buildSentRequestsList(context, colorScheme, textTheme, sentRequests),
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
    List<Map<String, String>> requests,
  ) {
    return SliverList.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['name']!, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Status: ${request['status']!}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Handle reject
                      },
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Handle accept
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
    List<Map<String, String>> requests,
  ) {
    return SliverList.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['name']!, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Status: ${request['status']!}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Handle withdraw
                      },
                      child: const Text('Withdraw'),
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
}

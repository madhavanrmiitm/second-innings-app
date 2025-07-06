import 'package:flutter/material.dart';
import 'local_groups_details.dart';

class LocalGroupsView extends StatelessWidget {
  const LocalGroupsView({super.key});

  // Sample data for local groups
  final List<Map<String, String>> localGroups = const [
    {
      'name': 'Senior Walkers Club',
      'description': 'Meet every morning for a walk in the park.',
      'whatsapp_link':
          'https://chat.whatsapp.com/your_whatsapp_group_link_here', // Add WhatsApp link
    },
    {
      'name': 'Book Readers Society',
      'description': 'Discuss books and enjoy literary events.',
      'whatsapp_link':
          'https://chat.whatsapp.com/your_whatsapp_group_link_here', // Add WhatsApp link
    },
    {
      'name': 'Gardening Enthusiasts',
      'description': 'Share tips and grow plants together.',
      'whatsapp_link':
          'https://chat.whatsapp.com/your_whatsapp_group_link_here', // Add WhatsApp link
    },
    {
      'name': 'Crafting Circle',
      'description': 'Work on various crafts and share your creations.',
      'whatsapp_link':
          'https://chat.whatsapp.com/your_whatsapp_group_link_here', // Add WhatsApp link
    },
    {
      'name': 'Bridge Club',
      'description': 'Enjoy friendly games of bridge.',
      'whatsapp_link':
          'https://chat.whatsapp.com/your_whatsapp_group_link_here', // Add WhatsApp link
    },
  ];

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
            snap: false,
            elevation: 0,
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Local Groups',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Join and participate in local activities',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Nearby Groups",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildLocalGroupsList(context, colorScheme),
          ),
        ],
      ),
    );
  }

  SliverList _buildLocalGroupsList(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return SliverList.builder(
      itemCount: localGroups.length,
      itemBuilder: (context, index) {
        final group = localGroups[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalGroupDetailsView(group: group),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer.withAlpha(
                      204,
                    ),
                    child: Icon(
                      Icons.group,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['name']!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          group['description']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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

import 'package:flutter/material.dart';

class LocalGroupsView extends StatelessWidget {
  const LocalGroupsView({super.key});

  // Sample data for local groups
  final List<Map<String, String>> localGroups = const [
    {
      'name': 'Senior Walkers Club',
      'description': 'Meet every morning for a walk in the park.',
    },
    {
      'name': 'Book Readers Society',
      'description': 'Discuss books and enjoy literary events.',
    },
    {
      'name': 'Gardening Enthusiasts',
      'description': 'Share tips and grow plants together.',
    },
    {
      'name': 'Crafting Circle',
      'description': 'Work on various crafts and share your creations.',
    },
    {'name': 'Bridge Club', 'description': 'Enjoy friendly games of bridge.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Groups')),
      body: ListView.builder(
        itemCount: localGroups.length,
        itemBuilder: (context, index) {
          final group = localGroups[index];
          return ListTile(
            title: Text(group['name']!),
            subtitle: Text(group['description']!),
            leading: const Icon(Icons.group), // Add an icon for visual appeal
            onTap: () {
              // TODO: Implement navigation or action when a group is tapped
            },
          );
        },
      ),
    );
  }
}

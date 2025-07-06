import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/edit_local_group_view.dart';

class MyLocalGroupsView extends StatelessWidget {
  const MyLocalGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Sample data for user-created groups
    final myGroups = [
      {'name': 'Morning Joggers', 'status': 'Approved'},
      {'name': 'Chess Masters', 'status': 'Pending'},
      {'name': 'Old School Movie Club', 'status': 'Rejected'},
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
            title: Text(
              'My Created Groups',
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
          SliverList.builder(
            itemCount: myGroups.length,
            itemBuilder: (context, index) {
              final group = myGroups[index];
              final status = group['status']!;
              final color = status == 'Approved'
                  ? colorScheme.primary
                  : status == 'Rejected'
                  ? colorScheme.error
                  : colorScheme.secondary;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: colorScheme.primaryContainer.withAlpha(51),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  title: Text(
                    group['name']!,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Status: $status',
                    style: textTheme.bodyMedium?.copyWith(color: color),
                  ),
                  trailing: status == 'Approved'
                      ? IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditLocalGroupView(groupData: group),
                              ),
                            );
                          },
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

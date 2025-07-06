import 'package:flutter/material.dart';

class ViewCurrentHiredCaregiverPage extends StatelessWidget {
  const ViewCurrentHiredCaregiverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Sample data for a hired caregiver
    const caregiver = {
      'name': 'Madhavan',
      'age': '31 yrs',
      'gender': 'Male',
      'desc':
          'I\'m proficient in medication management, mobility assistance, and creating engaging daily routines, all while fostering a warm and respectful environment.',
      'tags': ['Half Day', 'Checkups'],
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
            title: Text(
              'Hired Caregiver',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caregiver['name'] as String,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${caregiver['age']} • ${caregiver['gender']}',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(caregiver['desc'] as String, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8.0,
                    children: (caregiver['tags'] as List<String>)
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: colorScheme.surface.withAlpha(128),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

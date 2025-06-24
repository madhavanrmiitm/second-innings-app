// caregiver_details_view.dart
import 'package:flutter/material.dart';
import 'package:second_innings/auth/welcome.dart';
import 'package:second_innings/dashboard/senior_citizen/views/caregivers_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/family_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/health_log_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/local_groups_view.dart';

class CaregiverDetailsView extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String desc;
  final List<String> tags;

  const CaregiverDetailsView({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.desc,
    required this.tags,
  });

  @override
  State<CaregiverDetailsView> createState() => _CaregiverDetailsViewState();
}

class _CaregiverDetailsViewState extends State<CaregiverDetailsView> {
  int _selectedIndex = 3;

  final List<Widget> _widgetOptions = <Widget>[
    const LocalGroupsView(),
    const FamilyView(),
    const HealthLogView(),
    const CaregiversView(),
  ];

  void _onItemTapped(int index) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => _widgetOptions[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
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
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '2nd Innings',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Welcome, Virat Kohli',
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${widget.age} • ${widget.gender}', style: textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Text(widget.desc, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8.0,
                    children: widget.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor:
                                  colorScheme.surface.withAlpha(128),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Caregiver hired successfully!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5E5C1),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text(
                    'Hire this Caregiver',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          NavigationBar(
            onDestinationSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                label: 'Local Groups',
              ),
              NavigationDestination(
                icon: Icon(Icons.family_restroom_outlined),
                label: 'Family',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                label: 'Health Log',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.person_search),
                label: 'Caregivers',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

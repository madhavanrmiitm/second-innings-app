// caregivers_view.dart (for Family)
import 'package:flutter/material.dart';
import 'package:second_innings/auth/welcome.dart';
import 'package:second_innings/dashboard/family/views/caregiver_details_view.dart';
import 'package:second_innings/dashboard/family/views/view_current_hired_caregiver_view.dart';
import 'package:second_innings/dashboard/family/views/caregiver_requests_view.dart';
import 'package:second_innings/widgets/feature_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Image.asset("assets/logo.png"),
                onPressed: () {
                  debugPrint('Logo tapped');
                },
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
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
                    'Welcome, Anushka Sharma',
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
                  const SizedBox(height: 16),
                  _buildSearchBar(colorScheme),
                  const SizedBox(height: 16),
                  Row(
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
                                builder: (context) =>
                                    const ViewCurrentHiredCaregiverPage(),
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
                          icon: Icons.request_page_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CaregiverRequestsPage(),
                              ),
                            );
                          },
                          colorScheme: colorScheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(colorScheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildCaregiverList(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search based on needs',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colorScheme.primaryContainer.withAlpha(51),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
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
              selectedColor: colorScheme.primaryContainer.withAlpha(102),
              checkmarkColor: colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCaregiverList(ColorScheme colorScheme, TextTheme textTheme) {
    final caregivers = [
      {
        'name': 'Ashwin',
        'age': '24 yrs',
        'gender': 'Male',
        'desc':
            'With over seven years of dedicated experience in elderly care, I offer compassionate and reliable support tailored to your loved one\'s unique needs.',
        'tags': ['Physio', 'Car Drives', 'Checkups'],
      },
      {
        'name': 'Madhavan',
        'age': '31 yrs',
        'gender': 'Male',
        'desc':
            'I\'m proficient in medication management, mobility assistance, and creating engaging daily routines, all while fostering a warm and respectful environment.',
        'tags': ['Half Day', 'Checkups'],
      },
    ];

    return SliverList.builder(
      itemCount: caregivers.length,
      itemBuilder: (context, index) {
        final caregiver = caregivers[index] as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: colorScheme.primaryContainer.withAlpha(51),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              hoverColor: colorScheme.primaryContainer.withAlpha(100),
              splashColor: colorScheme.primary.withAlpha(80),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CaregiverDetailsView(
                      name: caregiver['name'] as String,
                      age: caregiver['age'] as String,
                      gender: caregiver['gender'] as String,
                      desc: caregiver['desc'] as String,
                      tags: List<String>.from(caregiver['tags'] as List),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caregiver['name'] as String,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${caregiver['age']} . ${caregiver['gender']}',
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      caregiver['desc'] as String,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: (caregiver['tags'] as List<dynamic>)
                          .map<Widget>(
                            (tag) => Chip(
                              label: Text(tag as String),
                              backgroundColor: colorScheme.surface.withAlpha(
                                128,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_details_view.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

class SeniorCitizensView extends StatelessWidget {
  const SeniorCitizensView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final seniorCitizens = [
      {'name': 'Leela', 'relation': 'Mom'},
      {'name': 'Ram', 'relation': 'Dad'},
      {'name': 'Krishna', 'relation': 'GrandDad'},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: '2nd Innings'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Senior Citizens",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "linked to me.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList.builder(
              itemCount: seniorCitizens.length,
              itemBuilder: (context, index) {
                final citizen = seniorCitizens[index];
                final name = citizen['name'] ?? '';
                final relation = citizen['relation'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeniorCitizenDetailPage(
                          name: name,
                          relation: relation,
                          selectedIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: Card(
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
                            backgroundColor: colorScheme.primaryContainer
                                .withAlpha(204),
                            child: Text(
                              name.isNotEmpty ? name[0] : '?',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                relation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withAlpha(128),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 20),
                                Icon(Icons.monitor_heart_outlined, size: 20),
                                Icon(Icons.square_foot, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_tasks_view.dart';
import 'package:second_innings/dashboard/family/views/all_reminders_for_senior_view.dart';

class SeniorCitizenDetailPage extends StatelessWidget {
  final String name;
  final String relation;
  final int selectedIndex;

  const SeniorCitizenDetailPage({
    super.key,
    required this.name,
    required this.relation,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                name,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Relation: $relation",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _FeatureCard(
                    title: "Tasks",
                    icon: Icons.checklist_rtl_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeniorCitizenTasksPage(
                            name: name,
                            relation: relation,
                          ),
                        ),
                      );
                    },
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),
                  _FeatureCard(
                    title: "Reminders",
                    icon: Icons.notifications_active_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllRemindersForSeniorPage(
                            name: name,
                            relation: relation,
                          ),
                        ),
                      );
                    },
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Delink"),
                          content: Text(
                            "Are you sure you want to delink $name?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Delink",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.link_off),
                    label: const Text("Delink Senior Citizen"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyHomePage(selectedIndex: index),
            ),
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Senior Citizens',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Caregivers'),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 28, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

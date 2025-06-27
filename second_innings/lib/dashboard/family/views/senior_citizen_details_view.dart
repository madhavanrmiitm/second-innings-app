import 'package:flutter/material.dart';
import 'package:second_innings/auth/welcome.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_health_logs_view.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_reminders_view.dart';

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
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Relation: $relation", style: textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeniorCitizenHealthLogsPage(
                            name: name,
                            relation: relation,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer.withAlpha(204),
                          child: Text("H", style: TextStyle(color: colorScheme.onPrimaryContainer)),
                        ),
                        title: Text("Display Health Logs", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeniorCitizenRemindersPage(
                            name: name,
                            relation: relation,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer.withAlpha(204),
                          child: Text("R", style: TextStyle(color: colorScheme.onPrimaryContainer)),
                        ),
                        title: Text("Reminders", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Delink"),
                          content: Text("Are you sure you want to delink $name?"),
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
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.red.withOpacity(0.2),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text("D", style: TextStyle(color: Colors.white)),
                        ),
                        title: Text("Delink Senior Citizen", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
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
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Caregivers',
          ),
        ],
      ),
    );
  }
}

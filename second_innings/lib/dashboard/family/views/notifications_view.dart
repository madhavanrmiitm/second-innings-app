import 'package:flutter/material.dart';
import 'package:second_innings/auth/welcome.dart';
import 'package:second_innings/dashboard/family/family_home.dart';

class NotificationsView extends StatelessWidget {
  final int selectedIndex;

  const NotificationsView({
    super.key,
    this.selectedIndex = 1, // Default to Notifications tab
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final todayNotifications = [
      "Doctor appointment at 5 PM.",
      "Daily walk completed.",
    ];

    final lastWeekNotifications = [
      "Medicine refilled on 23rd May.",
      "Video call scheduled.",
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
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
              titlePadding: const EdgeInsets.only(bottom: 16),
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
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today, 29th May",
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...todayNotifications.map(
                    (notification) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: ListTile(
                        title: Text(notification),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Last Week, 23rd May",
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...lastWeekNotifications.map(
                    (notification) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: ListTile(
                        title: Text(notification),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: selectedIndex,
      //   onDestinationSelected: (index) {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => FamilyHomePage(selectedIndex: index),
      //       ),
      //     );
      //   },
      //   destinations: const [
      //     NavigationDestination(
      //       icon: Icon(Icons.groups_outlined),
      //       label: 'Senior Citizens',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.notifications_outlined),
      //       label: 'Notifications',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.search),
      //       label: 'Caregivers',
      //     ),
      //   ],
      // ),
    );
  }
}

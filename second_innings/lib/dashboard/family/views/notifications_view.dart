import 'package:flutter/material.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

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
          const UserAppBar(title: '2nd Innings', showBackButton: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today, 29th May",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                      child: ListTile(title: Text(notification)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Last Week, 23rd May",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                      child: ListTile(title: Text(notification)),
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

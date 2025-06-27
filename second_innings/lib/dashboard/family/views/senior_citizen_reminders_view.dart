// import 'package:flutter/material.dart';
// import 'package:second_innings/auth/welcome.dart';
// import 'package:second_innings/dashboard/family/family_home.dart';

// class SeniorCitizenRemindersPage extends StatelessWidget {
//   final String name;
//   final String relation;
//   final int selectedIndex;

//   const SeniorCitizenRemindersPage({
//     super.key,
//     required this.name,
//     required this.relation,
//     this.selectedIndex = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     final reminders = [
//       "Call at 8:30 PM daily",
//       "Morning walk at 7:00 AM",
//       "Take medicine at 9:00 AM",
//     ];

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar.large(
//             pinned: true,
//             floating: true,
//             elevation: 0,
//             backgroundColor: colorScheme.primaryContainer.withAlpha(204),
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.logout_rounded),
//                 onPressed: () {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(builder: (context) => const WelcomeScreen()),
//                     (route) => false,
//                   );
//                 },
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               title: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '2nd Innings',
//                     style: textTheme.titleLarge?.copyWith(
//                       color: colorScheme.onPrimaryContainer,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Welcome, Anushka Sharma',
//                     style: textTheme.bodySmall?.copyWith(
//                       color: colorScheme.onPrimaryContainer,
//                     ),
//                   ),
//                 ],
//               ),
//               titlePadding: const EdgeInsets.only(bottom: 16),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   Text("Relation: $relation", style: textTheme.bodyLarge),
//                   const SizedBox(height: 24),
//                   Text(
//                     "Reminders",
//                     style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   ...reminders.map(
//                     (reminder) => Card(
//                       elevation: 0,
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       color: colorScheme.primaryContainer.withAlpha(51),
//                       child: ListTile(
//                         title: Text(reminder),
//                         trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
//                         onTap: () {
//                           // You can handle tapping a reminder here if you like
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Center(
//                     child: GestureDetector(
//                       onTap: () {
//                         // Handle add new reminder here
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: colorScheme.primary,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.add, color: Colors.white),
//                             const SizedBox(width: 8),
//                             Text(
//                               "Add New Reminder",
//                               style: textTheme.bodyLarge?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: selectedIndex,
//         onDestinationSelected: (index) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FamilyHomePage(selectedIndex: index),
//             ),
//           );
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.groups_outlined),
//             label: 'Senior Citizens',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.notifications_outlined),
//             label: 'Notifications',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.search),
//             label: 'Caregivers',
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:second_innings/auth/welcome.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_new_reminder_view.dart';

class SeniorCitizenRemindersPage extends StatelessWidget {
  final String name;
  final String relation;
  final int selectedIndex;

  const SeniorCitizenRemindersPage({
    super.key,
    required this.name,
    required this.relation,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final reminders = [
      "Call at 8:30 PM daily",
      "Morning walk at 7:00 AM",
      "Take medicine at 9:00 AM",
    ];

    return Scaffold(
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
                    name,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Relation: $relation", style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text(
                    "Reminders",
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...reminders.map(
                    (reminder) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: ListTile(
                        title: Text(reminder),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                        onTap: () {
                          // Optionally handle reminder tap
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeniorCitizenNewReminderPage(name: name),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(51),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Add New Reminder",
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
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

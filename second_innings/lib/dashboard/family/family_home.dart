// import 'package:flutter/material.dart';
// import 'package:second_innings/dashboard/family/views/caregivers_view.dart';
// import 'package:second_innings/dashboard/family/views/notifications_view.dart';
// import 'package:second_innings/dashboard/family/views/senior_citizens_view.dart';
// import 'package:second_innings/dashboard/family/views/link_new_senior_citizen_view.dart';

// class FamilyHomePage extends StatefulWidget {
//   const FamilyHomePage({super.key});

//   @override
//   State<FamilyHomePage> createState() => _FamilyHomePageState();
// }

// class _FamilyHomePageState extends State<FamilyHomePage> {
//   int _selectedIndex = 0;

//   static const List<Widget> _widgetOptions = <Widget>[
//     SeniorCitizensView(),
//     NotificationsView(),
//     CaregiversView(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgetOptions[_selectedIndex],
//       floatingActionButton: _selectedIndex == 0
//           ? FloatingActionButton.extended(
//               heroTag: 'linkNewFab', // Important: Avoid Hero conflict
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const LinkNewSeniorCitizenPage(),
//                   ),
//                 );
//               },
//               label: const Text('Link New'),
//               icon: const Icon(Icons.add),
//             )
//           : null,
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: _onItemTapped,
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
import 'package:second_innings/dashboard/family/views/caregivers_view.dart';
import 'package:second_innings/dashboard/family/views/notifications_view.dart';
import 'package:second_innings/dashboard/family/views/senior_citizens_view.dart';
import 'package:second_innings/dashboard/family/views/link_new_senior_citizen_view.dart';
import 'package:second_innings/dashboard/family/views/profile_view.dart';
import 'package:second_innings/dashboard/family/views/family_tasks_view.dart';
import 'package:second_innings/dashboard/family/views/create_family_task_page.dart';

class FamilyHomePage extends StatefulWidget {
  final int selectedIndex;

  const FamilyHomePage({super.key, this.selectedIndex = 0});

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const SeniorCitizensView(),
      const FamilyTasksView(),
      const NotificationsView(),
      const CaregiversView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              heroTag: 'linkNewFab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LinkNewSeniorCitizenPage(),
                  ),
                );
              },
              label: const Text('Link New'),
              icon: const Icon(Icons.add),
            )
          : _selectedIndex == 1
          ? FloatingActionButton.extended(
              heroTag: 'familyTasksFab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateFamilyTaskPage(),
                  ),
                );
              },
              label: const Text('Create Task'),
              icon: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Senior Citizens',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            label: 'My Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Caregivers'),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

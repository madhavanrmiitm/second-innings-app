import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/caregivers_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/family_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/health_log_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/local_groups_view.dart';

class SeniorCitizenHomePage extends StatefulWidget {
  const SeniorCitizenHomePage({super.key});

  @override
  State<SeniorCitizenHomePage> createState() => _SeniorCitizenHomePageState();
}

class _SeniorCitizenHomePageState extends State<SeniorCitizenHomePage> {
  int _selectedIndex = 3; // Start at Caregivers tab

  static const List<Widget> _widgetOptions = <Widget>[
    LocalGroupsView(),
    FamilyView(),
    HealthLogView(),
    CaregiversView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
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
    );
  }
}

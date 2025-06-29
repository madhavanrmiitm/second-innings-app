import 'package:flutter/material.dart';

class FamilyView extends StatelessWidget {
  const FamilyView({super.key});

  // Sample data for family members
  final List<Map<String, String>> familyMembers = const [
    {'name': 'John Doe', 'relationship': 'Son'},
    {'name': 'Jane Doe', 'relationship': 'Daughter'},
    {'name': 'Peter Smith', 'relationship': 'Grandson'},
    {'name': 'Mary Smith', 'relationship': 'Granddaughter'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: ListView.builder(
        itemCount: familyMembers.length,
        itemBuilder: (context, index) {
          final member = familyMembers[index];
          return ListTile(
            leading: const Icon(
              Icons.person,
            ), // You can replace this with a profile picture
            title: Text(member['name']!),
            subtitle: Text(member['relationship']!),
            // Add onTap functionality if needed
          );
        },
      ),
    );
  }
}

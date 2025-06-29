import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  // Sample list of notifications
  final List<Map<String, String>> notifications = const [
    {'title': 'Medication Reminder', 'subtitle': 'Time to take Ibuprofen'},
    {'title': 'Appointment Reminder', 'subtitle': 'Appointment with Dr. Smith at 3 PM'},
    {'title': 'New Message', 'subtitle': 'You have a new message from John Doe'},
    {'title': 'Activity Alert', 'subtitle': 'Patient activity detected'},
    {'title': 'System Update', 'subtitle': 'App update available'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notifications[index]['title']!),
            subtitle: Text(notifications[index]['subtitle']!),
          );
        },
      ),
    );
  }
}

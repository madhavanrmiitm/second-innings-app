import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  // Sample notifications data
  final List<Map<String, String>> notifications = const [
    {'title': 'Medication Reminder', 'message': 'It\'s time for Grandma\'s medication.'},
    {'title': 'Appointment Alert', 'message': 'Dr. Smith appointment tomorrow at 10 AM.'},
    {'title': 'Activity Update', 'message': 'Dad completed his walking exercise today.'},
    {'title': 'Message from Caregiver', 'message': 'Caregiver left a new message.'},
    {'title': 'System Notification', 'message': 'Your profile information was updated.'},
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
            subtitle: Text(notifications[index]['message']!),
          );
        },
      ),
    );
  }
}

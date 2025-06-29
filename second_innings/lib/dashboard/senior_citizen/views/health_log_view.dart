import 'package:flutter/material.dart';

class HealthLogView extends StatelessWidget {
  const HealthLogView({super.key});

  // Sample health log entries
  final List<Map<String, String>> _healthLogs = const [
    {'date': '2023-10-26', 'description': 'Blood pressure check: 120/80'},
    {'date': '2023-10-25', 'description': 'Took medication as prescribed'},
    {'date': '2023-10-24', 'description': 'Felt a bit tired today'},
    {'date': '2023-10-23', 'description': 'Went for a short walk in the park'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Log')),
      body: ListView.builder(
        itemCount: _healthLogs.length,
        itemBuilder: (context, index) {
          final logEntry = _healthLogs[index];
          return ListTile(
            title: Text(logEntry['date']!),
            subtitle: Text(logEntry['description']!),
          );
        },
      ),
    );
  }
}

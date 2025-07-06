import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/new_reminder_for_senior_view.dart';

class AllRemindersForSeniorPage extends StatefulWidget {
  final String name;
  final String relation;

  const AllRemindersForSeniorPage({
    super.key,
    required this.name,
    required this.relation,
  });

  @override
  State<AllRemindersForSeniorPage> createState() =>
      _AllRemindersForSeniorPageState();
}

class _AllRemindersForSeniorPageState extends State<AllRemindersForSeniorPage> {
  final List<Map<String, dynamic>> _reminders = [
    {'title': "Call at 8:30 PM daily", 'completed': false},
    {'title': "Ask about morning walk at 7:00 AM", 'completed': true},
    {'title': "Remind to take medicine at 9:00 AM", 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reminders for ${widget.name}',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.relation,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: reminder['completed']
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primaryContainer.withAlpha(100),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    title: Text(
                      reminder['title']!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: reminder['completed']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Checkbox(
                      value: reminder['completed'],
                      onChanged: (bool? value) {
                        setState(() {
                          _reminders[index]['completed'] = value!;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewReminderForSeniorPage(
                name: widget.name,
                relation: widget.relation,
              ),
            ),
          );
        },
        label: const Text('New Reminder'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

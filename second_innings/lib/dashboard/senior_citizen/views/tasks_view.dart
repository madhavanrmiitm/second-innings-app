import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/create_new_task_page.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  // Sample task entries
  final List<Map<String, dynamic>> _tasks = [
    {
      'type': 'self',
      'description': 'Blood pressure check: 120/80',
      'done': true,
    },
    {
      'type': 'family',
      'description': 'Took medication as prescribed',
      'done': false,
    },
    {'type': 'self', 'description': 'Felt a bit tired today', 'done': false},
    {
      'type': 'family',
      'description': 'Went for a short walk in the park',
      'done': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: 'Tasks'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    "Your Tasks",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildTasksList(colorScheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "senior_citizen_tasks_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNewTaskPage()),
          );
        },
        label: const Text('Create New'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  SliverList _buildTasksList(ColorScheme colorScheme) {
    return SliverList.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer.withAlpha(204),
                  child: Icon(
                    task['type'] == 'family'
                        ? Icons.family_restroom_outlined
                        : Icons.person_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['description']!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: task['done'],
                  onChanged: (bool? value) {
                    setState(() {
                      _tasks[index]['done'] = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

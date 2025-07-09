import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_new_task_view.dart';

class SeniorCitizenTasksPage extends StatefulWidget {
  final String name;
  final String relation;

  const SeniorCitizenTasksPage({
    super.key,
    required this.name,
    required this.relation,
  });

  @override
  State<SeniorCitizenTasksPage> createState() => _SeniorCitizenTasksPageState();
}

class _SeniorCitizenTasksPageState extends State<SeniorCitizenTasksPage> {
  // Sample task entries
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Buy groceries', 'dueDate': '2023-10-28', 'completed': false},
    {
      'title': 'Schedule doctor appointment',
      'dueDate': '2023-10-29',
      'completed': false,
    },
    {
      'title': 'Pay electricity bill',
      'dueDate': '2023-10-27',
      'completed': true,
    },
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
                    widget.name,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Text(
                "Tasks",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildTaskList(colorScheme, textTheme),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "family_senior_tasks_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeniorCitizenNewTaskPage(
                name: widget.name,
                relation: widget.relation,
              ),
            ),
          );
        },
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  SliverList _buildTaskList(ColorScheme colorScheme, TextTheme textTheme) {
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
          color: task['completed']
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer.withAlpha(100),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            title: Text(
              task['title']!,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: task['completed']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(
              'Due: ${task['dueDate']}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                decoration: task['completed']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Checkbox(
              value: task['completed'],
              onChanged: (bool? value) {
                setState(() {
                  _tasks[index]['completed'] = value!;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

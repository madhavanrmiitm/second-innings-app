import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_new_task_view.dart';
import 'package:second_innings/services/task_service.dart';
import 'package:second_innings/services/user_service.dart';

class SeniorCitizenTasksPage extends StatefulWidget {
  final String name;
  final String relation;
  final String? seniorCitizenFirebaseUid;

  const SeniorCitizenTasksPage({
    super.key,
    required this.name,
    required this.relation,
    this.seniorCitizenFirebaseUid,
  });

  @override
  State<SeniorCitizenTasksPage> createState() => _SeniorCitizenTasksPageState();
}

class _SeniorCitizenTasksPageState extends State<SeniorCitizenTasksPage> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await TaskService.getTasks();

      if (response.statusCode == 200) {
        final tasksData = response.data?['data']?['tasks'] as List?;
        if (tasksData != null) {
          // Filter tasks for the specific senior citizen if firebase_uid is provided
          List<Map<String, dynamic>> filteredTasks = tasksData
              .cast<Map<String, dynamic>>();
          if (widget.seniorCitizenFirebaseUid != null) {
            filteredTasks = filteredTasks
                .where(
                  (task) =>
                      task['assigned_to'] == widget.seniorCitizenFirebaseUid,
                )
                .toList();
          }

          setState(() {
            _tasks = filteredTasks;
            _isLoading = false;
          });
        } else {
          setState(() {
            _tasks = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load tasks';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _completeTask(String taskId) async {
    try {
      final response = await TaskService.completeTask(taskId: taskId);

      if (response.statusCode == 200) {
        // Reload tasks to reflect the change
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to complete task')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error completing task: $e')));
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final response = await TaskService.deleteTask(taskId);

      if (response.statusCode == 200) {
        // Reload tasks to reflect the change
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to delete task')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
    }
  }

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
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    _error!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            )
          else
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
                seniorCitizenFirebaseUid: widget.seniorCitizenFirebaseUid,
              ),
            ),
          ).then((_) => _loadTasks());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTaskList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_tasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.task_alt, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No tasks found',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final isCompleted = task['status'] == 'completed';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: isCompleted
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer.withAlpha(100),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            title: Text(
              task['title'] ?? 'Untitled Task',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task['description'] != null)
                  Text(
                    task['description'],
                    style: textTheme.bodySmall?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                if (task['time_of_completion'] != null)
                  Text(
                    'Due: ${task['time_of_completion']}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCompleted)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => _completeTask(task['id']),
                    tooltip: 'Complete Task',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteTask(task['id']),
                  tooltip: 'Delete Task',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

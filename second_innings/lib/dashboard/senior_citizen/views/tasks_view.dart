import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/create_new_task_page.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/task_service.dart';
import 'package:second_innings/services/user_service.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
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
          setState(() {
            _tasks = tasksData.cast<Map<String, dynamic>>();
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

  Future<void> _refreshTasks() async {
    await _loadTasks();
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

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title'] ?? '');
    final descriptionController = TextEditingController(
      text: task['description'] ?? '',
    );
    final timeController = TextEditingController(
      text: task['time_of_completion'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Due Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateTask(
                task['id'].toString(),
                titleController.text,
                descriptionController.text,
                timeController.text.isNotEmpty ? timeController.text : null,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTask(
    String taskId,
    String title,
    String description,
    String? timeOfCompletion,
  ) async {
    try {
      final response = await TaskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        timeOfCompletion: timeOfCompletion,
      );

      if (response.statusCode == 200) {
        await _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to update task')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: const Text('Tasks'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshTasks,
                  tooltip: 'Refresh Tasks',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      "Your Tasks",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildTasksList(colorScheme),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "senior_citizen_tasks_fab",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNewTaskPage()),
          );
          // Reload tasks if a new task was created
          if (result == true) {
            await _loadTasks();
          }
        },
        label: const Text('Create New'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksList(ColorScheme colorScheme) {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final isCompleted = task['status'] == 'completed';
        final isAssigned = task['assigned_to'] != null;
        final isCreatedByMe =
            task['created_by'] == task['assigned_to'] ||
            task['assigned_to'] == null;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: isCompleted
              ? colorScheme.surfaceVariant.withAlpha(51)
              : colorScheme.primaryContainer.withAlpha(51),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isAssigned
                          ? colorScheme.secondaryContainer.withAlpha(204)
                          : colorScheme.primaryContainer.withAlpha(204),
                      child: Icon(
                        isAssigned
                            ? Icons.family_restroom_outlined
                            : Icons.person_outline,
                        color: isAssigned
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] ?? 'Untitled Task',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task['description'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          if (task['time_of_completion'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Due: ${task['time_of_completion']}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isCompleted)
                      Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) {
                          _completeTask(task['id'].toString());
                        },
                      ),
                  ],
                ),
                if (!isCompleted && isCreatedByMe) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showEditTaskDialog(task),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _deleteTask(task['id'].toString()),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

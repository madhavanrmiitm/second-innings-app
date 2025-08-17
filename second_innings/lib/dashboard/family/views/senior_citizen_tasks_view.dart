import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/senior_citizen_new_task_view.dart';
import 'package:second_innings/services/task_service.dart';
import 'package:second_innings/services/user_service.dart';

class SeniorCitizenTasksPage extends StatefulWidget {
  final String name;
  final String relation;
  final String? seniorCitizenFirebaseUid;
  final Map<String, dynamic>? seniorCitizenData;

  const SeniorCitizenTasksPage({
    super.key,
    required this.name,
    required this.relation,
    this.seniorCitizenFirebaseUid,
    this.seniorCitizenData,
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
      // Get the senior citizen ID from the data
      String? seniorCitizenId;
      if (widget.seniorCitizenData != null) {
        seniorCitizenId = widget.seniorCitizenData!['id']?.toString();
      }

      final response = await TaskService.getTasks(
        seniorCitizenId: seniorCitizenId,
      );

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
                      task['assigned_to'] == widget.seniorCitizenFirebaseUid ||
                      task['created_by'] == widget.seniorCitizenFirebaseUid,
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              floating: true,
              elevation: 0,
              backgroundColor: colorScheme.primaryContainer.withAlpha(204),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshTasks,
                  tooltip: 'Refresh Tasks',
                ),
              ],
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
                seniorCitizenData: widget.seniorCitizenData,
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
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer.withAlpha(100),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] ?? 'Untitled Task',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          if (task['description'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              task['description'],
                              style: textTheme.bodySmall?.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ],
                          if (task['time_of_completion'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Due: ${task['time_of_completion']}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isCompleted)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => _completeTask(task['id'].toString()),
                        tooltip: 'Complete Task',
                      ),
                  ],
                ),
                if (!isCompleted) ...[
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

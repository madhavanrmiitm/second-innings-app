import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/family/views/new_reminder_for_senior_view.dart';
import 'package:second_innings/services/task_service.dart';

class AllRemindersForSeniorPage extends StatefulWidget {
  final String name;
  final String relation;
  final String? seniorCitizenFirebaseUid;

  const AllRemindersForSeniorPage({
    super.key,
    required this.name,
    required this.relation,
    this.seniorCitizenFirebaseUid,
  });

  @override
  State<AllRemindersForSeniorPage> createState() =>
      _AllRemindersForSeniorPageState();
}

class _AllRemindersForSeniorPageState extends State<AllRemindersForSeniorPage> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await TaskService.getReminders();

      if (response.statusCode == 200) {
        final remindersData = response.data?['data']?['reminders'] as List?;
        if (remindersData != null) {
          // Filter reminders for the specific senior citizen if firebase_uid is provided
          List<Map<String, dynamic>> filteredReminders = remindersData
              .cast<Map<String, dynamic>>();
          if (widget.seniorCitizenFirebaseUid != null) {
            filteredReminders = filteredReminders
                .where(
                  (reminder) =>
                      reminder['assigned_to'] ==
                      widget.seniorCitizenFirebaseUid,
                )
                .toList();
          }

          setState(() {
            _reminders = filteredReminders;
            _isLoading = false;
          });
        } else {
          setState(() {
            _reminders = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load reminders';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading reminders: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _snoozeReminder(String reminderId) async {
    try {
      final response = await TaskService.snoozeReminder(reminderId: reminderId);

      if (response.statusCode == 200) {
        // Reload reminders to reflect the change
        await _loadReminders();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder snoozed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to snooze reminder'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error snoozing reminder: $e')));
    }
  }

  Future<void> _cancelReminder(String reminderId) async {
    try {
      final response = await TaskService.cancelReminder(reminderId);

      if (response.statusCode == 200) {
        // Reload reminders to reflect the change
        await _loadReminders();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder cancelled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to cancel reminder'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cancelling reminder: $e')));
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
              padding: const EdgeInsets.all(16.0),
              sliver: _buildRemindersList(colorScheme, textTheme),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "family_reminders_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewReminderForSeniorPage(
                name: widget.name,
                relation: widget.relation,
                seniorCitizenFirebaseUid: widget.seniorCitizenFirebaseUid,
              ),
            ),
          ).then((_) => _loadReminders());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildRemindersList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_reminders.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.alarm, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No reminders found',
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
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        final isCompleted = reminder['status'] == 'completed';

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
              reminder['title'] ?? 'Untitled Reminder',
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
                if (reminder['description'] != null)
                  Text(
                    reminder['description'],
                    style: textTheme.bodySmall?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                if (reminder['reminder_time'] != null)
                  Text(
                    'Reminder: ${reminder['reminder_time']}',
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
                    icon: const Icon(Icons.snooze),
                    onPressed: () => _snoozeReminder(reminder['id']),
                    tooltip: 'Snooze Reminder',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _cancelReminder(reminder['id']),
                  tooltip: 'Cancel Reminder',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

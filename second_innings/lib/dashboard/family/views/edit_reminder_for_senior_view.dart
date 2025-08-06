import 'package:flutter/material.dart';
import 'package:second_innings/services/task_service.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

class EditReminderForSeniorPage extends StatefulWidget {
  final String reminderId;
  final Map<String, dynamic> reminderData;

  const EditReminderForSeniorPage({
    super.key,
    required this.reminderId,
    required this.reminderData,
  });

  @override
  State<EditReminderForSeniorPage> createState() =>
      _EditReminderForSeniorPageState();
}

class _EditReminderForSeniorPageState extends State<EditReminderForSeniorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _timeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.reminderData['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.reminderData['description'] ?? '',
    );

    // Parse and format the reminder time
    final reminderTime = widget.reminderData['reminder_time'];
    if (reminderTime != null) {
      try {
        final date = DateTime.parse(reminderTime);
        _timeController = TextEditingController(
          text:
              "${date.day.toString().padLeft(2, '0')} / "
              "${date.month.toString().padLeft(2, '0')} / "
              "${date.year} ${date.hour.toString().padLeft(2, '0')}:"
              "${date.minute.toString().padLeft(2, '0')}",
        );
      } catch (e) {
        _timeController = TextEditingController();
      }
    } else {
      _timeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _updateReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse the date and time from the form format
      final timeParts = _timeController.text.split(' ');
      String? formattedDateTime;

      if (timeParts.length >= 4) {
        final dateParts = timeParts[0].split(' / ');
        final timeParts2 = timeParts[3].split(':');

        if (dateParts.length == 3 && timeParts2.length == 2) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          final hour = int.parse(timeParts2[0]);
          final minute = int.parse(timeParts2[1]);

          final reminderDateTime = DateTime(year, month, day, hour, minute);

          // Format datetime for API (ISO format)
          formattedDateTime = reminderDateTime.toIso8601String();
        }
      }

      final response = await TaskService.updateReminder(
        reminderId: widget.reminderId,
        title: _titleController.text,
        description: _descriptionController.text,
        reminderTime: formattedDateTime,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder updated successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to update reminder'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating reminder: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            floating: false,
            elevation: 0,
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Reminder',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Update reminder details',
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
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Reminder Title',
                        prefixIcon: const Icon(Icons.alarm_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (pickedDate != null) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            final combinedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            String formattedDateTime =
                                "${combinedDateTime.day.toString().padLeft(2, '0')} / "
                                "${combinedDateTime.month.toString().padLeft(2, '0')} / "
                                "${combinedDateTime.year} "
                                "${combinedDateTime.hour.toString().padLeft(2, '0')}:"
                                "${combinedDateTime.minute.toString().padLeft(2, '0')}";
                            _timeController.text = formattedDateTime;
                          }
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Reminder Time',
                        prefixIcon: const Icon(Icons.access_time_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Reminder time is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _updateReminder,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _isLoading ? 'Updating...' : 'Update Reminder',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

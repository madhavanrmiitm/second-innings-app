import 'package:flutter/material.dart';

class NewReminderForSeniorPage extends StatefulWidget {
  final String name;
  final String relation;

  const NewReminderForSeniorPage({
    super.key,
    required this.name,
    required this.relation,
  });

  @override
  State<NewReminderForSeniorPage> createState() =>
      _NewReminderForSeniorPageState();
}

class _NewReminderForSeniorPageState extends State<NewReminderForSeniorPage> {
  bool _isVoiceInput = true;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    _isVoiceInput ? Icons.edit_note_rounded : Icons.mic_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _isVoiceInput = !_isVoiceInput;
                    });
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Reminder',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'for ${widget.name}',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _isVoiceInput
                      ? _buildVoiceInputUI(context)
                      : _buildManualInputUI(context),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_isVoiceInput) {
                        Navigator.pop(context);
                      } else {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Add Reminder'),
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
        ],
      ),
    );
  }

  Widget _buildVoiceInputUI(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.mic,
            size: 150,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tap on the mic icon and state the reminder. It will be automatically created.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildManualInputUI(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Reminder Title',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          hintText: 'e.g., Call mom at 8 PM',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
    );
  }
}

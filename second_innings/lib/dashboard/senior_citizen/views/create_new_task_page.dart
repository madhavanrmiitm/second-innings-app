import 'package:flutter/material.dart';

class CreateNewTaskPage extends StatefulWidget {
  const CreateNewTaskPage({super.key});

  @override
  State<CreateNewTaskPage> createState() => _CreateNewTaskPageState();
}

class _CreateNewTaskPageState extends State<CreateNewTaskPage> {
  bool _isVoiceInput = true;
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
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
                    'New Task',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Create a new task for yourself',
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
                        // TODO: Implement voice log creation
                        Navigator.pop(context);
                      } else {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Implement manual log creation
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Create New Task'),
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
          'Tap on the mic icon, talk about whatever you want to be in the task, The task will be created automatically for you!',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildManualInputUI(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
                _dateController.text = formattedDate;
              }
            },
            decoration: InputDecoration(
              labelText: 'Date',
              hintText: 'DD / MM / YYYY',
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Date is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter the task details',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Description is required.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

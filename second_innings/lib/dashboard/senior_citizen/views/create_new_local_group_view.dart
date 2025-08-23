import 'package:flutter/material.dart';
import 'package:second_innings/services/interest_group_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class CreateNewLocalGroupView extends StatefulWidget {
  const CreateNewLocalGroupView({super.key});

  @override
  State<CreateNewLocalGroupView> createState() =>
      _CreateNewLocalGroupViewState();
}

class _CreateNewLocalGroupViewState extends State<CreateNewLocalGroupView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _whatsappLinkController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _selectedDateTime;

  // Speech-to-text variables
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _whatsappLinkController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// Initialize speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _isListening = false;
        });
      },
      onStatus: (status) {
        print('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
    setState(() {});
  }

  /// Start listening for speech
  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
    setState(() {
      _isListening = true;
    });
  }

  /// Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      if (result.finalResult) {
        // Append the recognized text to the current description
        final currentText = _descriptionController.text;
        final newText = currentText.isEmpty
            ? result.recognizedWords
            : '$currentText ${result.recognizedWords}';
        _descriptionController.text = newText;

        // Show brief success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voice input added: "${result.recognizedWords}"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String? _formatDateTimeForAPI() {
    if (_selectedDateTime == null) return null;
    // Format as PostgreSQL TIMESTAMP: YYYY-MM-DD HH:MM:SS
    return _selectedDateTime!.toIso8601String().substring(0, 19);
  }

  Future<void> _createGroup() async {
    try {
      final response = await InterestGroupService.createInterestGroup(
        title: _titleController.text,
        description: _descriptionController.text,
        whatsappLink: _whatsappLinkController.text.isNotEmpty
            ? _whatsappLinkController.text
            : null,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        timing: _formatDateTimeForAPI(),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to create group')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating group: $e')));
    }
  }

  String? _validateWhatsAppLink(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!value.startsWith('https://chat.whatsapp.com/')) {
      return 'WhatsApp link must start with "https://chat.whatsapp.com/"';
    }
    return null;
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
            title: Text(
              'Create New Group',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Group Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Enter a descriptive name for your group',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a group name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Describe what this group is about',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Voice input button
                            IconButton(
                              onPressed: _isListening
                                  ? _stopListening
                                  : _startListening,
                              icon: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: _isListening
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                              tooltip: _isListening
                                  ? 'Stop voice input'
                                  : 'Start voice input',
                            ),
                            // Clear text button
                            if (_descriptionController.text.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _descriptionController.clear();
                                  });
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                tooltip: 'Clear description',
                              ),
                          ],
                        ),
                        // Show listening indicator
                        helperText: _isListening
                            ? 'Listening... Speak now'
                            : 'Type or use the microphone to describe your group',
                      ),
                      maxLines: 4,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    // Voice input status indicator
                    if (_isListening) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withAlpha(100),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.error.withAlpha(100),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic, color: colorScheme.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Voice input active - Speak clearly into your microphone',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., Sports, Music, Technology, etc.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Meeting Time',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedDateTime != null
                                        ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Select meeting date and time',
                                    style: TextStyle(
                                      color: _selectedDateTime != null
                                          ? Colors.black
                                          : Colors.grey.shade500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whatsappLinkController,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp Group Link',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'https://chat.whatsapp.com/...',
                        helperText: 'Optional: Add your WhatsApp group link',
                      ),
                      validator: _validateWhatsAppLink,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _createGroup();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Create Group'),
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

import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

enum FeedbackCategory { feedback, query, help }

class FeedbackQueryHelpPage extends StatefulWidget {
  const FeedbackQueryHelpPage({super.key});

  @override
  State<FeedbackQueryHelpPage> createState() => _FeedbackQueryHelpPageState();
}

class _FeedbackQueryHelpPageState extends State<FeedbackQueryHelpPage> {
  Set<FeedbackCategory> _selection = {FeedbackCategory.feedback};
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _getCategoryString(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.feedback:
        return 'feedback';
      case FeedbackCategory.query:
        return 'query';
      case FeedbackCategory.help:
        return 'help';
    }
  }

  String _getPriorityString(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.feedback:
        return 'low';
      case FeedbackCategory.query:
        return 'medium';
      case FeedbackCategory.help:
        return 'high';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final selectedCategory = _selection.first;
      final category = _getCategoryString(selectedCategory);
      final priority = _getPriorityString(selectedCategory);

      // Create a descriptive subject based on the category
      String subject;
      switch (selectedCategory) {
        case FeedbackCategory.feedback:
          subject = 'Feedback - ${_emailController.text}';
          break;
        case FeedbackCategory.query:
          subject = 'General Query - ${_emailController.text}';
          break;
        case FeedbackCategory.help:
          subject = 'Help Request - ${_emailController.text}';
          break;
      }

      final response = await TicketService.createTicket(
        subject: subject,
        description: _messageController.text,
        priority: priority,
        category: category,
      );

      if (response.isSuccess) {
        setState(() {
          _successMessage = response.message ?? 'Message sent successfully!';
          _messageController.clear();
        });

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });
      } else {
        setState(() {
          _errorMessage =
              response.error ?? 'Failed to send message. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback, Queries & Help")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'How can we help you?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: SegmentedButton<FeedbackCategory>(
                    segments: const <ButtonSegment<FeedbackCategory>>[
                      ButtonSegment<FeedbackCategory>(
                        value: FeedbackCategory.feedback,
                        label: Text('Feedback'),
                        icon: Icon(Icons.feedback_outlined),
                      ),
                      ButtonSegment<FeedbackCategory>(
                        value: FeedbackCategory.query,
                        label: Text('Query'),
                        icon: Icon(Icons.quiz_outlined),
                      ),
                      ButtonSegment<FeedbackCategory>(
                        value: FeedbackCategory.help,
                        label: Text('Help'),
                        icon: Icon(Icons.support_agent_outlined),
                      ),
                    ],
                    selected: _selection,
                    onSelectionChanged: (Set<FeedbackCategory> newSelection) {
                      setState(() {
                        if (newSelection.isNotEmpty) {
                          _selection = newSelection;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a short title';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Short title',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your message';
                    }
                    if (value.trim().length < 10) {
                      return 'Message must be at least 10 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Type your description here...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Success message
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32.0),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isLoading ? 'Sending...' : 'Send Message'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

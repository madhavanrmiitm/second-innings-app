import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback, Queries & Help")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  hintText: 'Enter your email address',
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
                decoration: InputDecoration(
                  labelText: 'Your Message',
                  hintText: 'Type your message here...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Implement Send logic
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send Message'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

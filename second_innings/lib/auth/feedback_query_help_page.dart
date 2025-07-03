import 'package:flutter/material.dart';

class FeedbackQueryHelpPage extends StatelessWidget {
  const FeedbackQueryHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback / Queries / Help"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Feedback logic
              },
              child: const Text('Feedback'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Query logic
              },
              child: const Text('Query'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Help logic
              },
              child: const Text('Help'),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Your Email:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Your Message:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your message here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Send logic
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

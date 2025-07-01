import 'package:flutter/material.dart';

class CreateNewHealthLogPage extends StatelessWidget {
  const CreateNewHealthLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Health Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Enter the date (e.g., 2023-10-27)',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              maxLines: null, // Allows for multi-line input
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter the health log details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement saving the health log
                  // For now, just navigate back
                  Navigator.pop(context);
                },
                child: const Text('Save Health Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

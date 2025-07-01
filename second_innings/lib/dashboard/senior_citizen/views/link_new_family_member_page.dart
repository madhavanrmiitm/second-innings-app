import 'package:flutter/material.dart';

class LinkNewFamilyMemberPage extends StatelessWidget {
  const LinkNewFamilyMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link New Family Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 16.0),
            TextField(decoration: InputDecoration(labelText: 'Relationship')),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement logic to save the new family member
                // and potentially navigate back or show a confirmation.
              },
              child: Text('Link Family Member'),
            ),
          ],
        ),
      ),
    );
  }
}

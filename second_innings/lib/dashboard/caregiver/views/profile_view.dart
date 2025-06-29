import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/150', // Placeholder image URL
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              initialValue: 'Rishabh Pant', // Example data
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              initialValue: '9876543210', // Example data
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              initialValue: 'rishabh.pant@gmail.com', // Example data
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Short Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              initialValue: 'Experienced caregiver with a passion for providing compassionate care.', // Example data
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

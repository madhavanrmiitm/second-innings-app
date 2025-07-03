import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalGroupDetailsView extends StatelessWidget {
  final Map<String, String> group;

  const LocalGroupDetailsView({required this.group, super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Add a placeholder for the WhatsApp link if it doesn't exist in the data
    final whatsappLink = group['whatsapp_link'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']!),
        backgroundColor: colorScheme.primaryContainer.withAlpha(204),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['name']!,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              group['description']!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (whatsappLink.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _launchUrl(whatsappLink),
                icon: const Icon(Icons.message),
                label: const Text('Join WhatsApp Group'),
              ),
          ],
        ),
      ),
    );
  }
}

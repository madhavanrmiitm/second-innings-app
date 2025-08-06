import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalGroupDetailsView extends StatelessWidget {
  final Map<String, dynamic> group;

  const LocalGroupDetailsView({required this.group, super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Add a placeholder for the WhatsApp link if it doesn't exist in the data
    final whatsappLink = group['link']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']?.toString() ?? 'Group Details'),
        backgroundColor: colorScheme.primaryContainer.withAlpha(204),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['name']?.toString() ?? 'Untitled Group',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: .5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  group['description']?.toString() ??
                      'No description available',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (whatsappLink.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(context, whatsappLink),
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text('Join Group Link'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

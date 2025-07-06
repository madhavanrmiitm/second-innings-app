import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.isColumn = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isColumn;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.primaryContainer.withAlpha(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isColumn
              ? Column(
                  children: [
                    Icon(icon, size: 28, color: colorScheme.onPrimaryContainer),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(icon, size: 28, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

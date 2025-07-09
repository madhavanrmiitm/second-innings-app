// caregiver_details_view.dart (for Senior Citizen)
import 'package:flutter/material.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

class CaregiverDetailsView extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String desc;
  final List<String> tags;

  const CaregiverDetailsView({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.desc,
    required this.tags,
  });

  @override
  State<CaregiverDetailsView> createState() => _CaregiverDetailsViewState();
}

class _CaregiverDetailsViewState extends State<CaregiverDetailsView> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: '2nd Innings', showBackButton: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.age} • ${widget.gender}',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(widget.desc, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8.0,
                    children: widget.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: colorScheme.surface.withAlpha(128),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Caregiver hired successfully!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5E5C1),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text(
                    'Hire this Caregiver',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

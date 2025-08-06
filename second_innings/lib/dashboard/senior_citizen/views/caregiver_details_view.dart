// caregiver_details_view.dart (for Senior Citizen)
import 'package:flutter/material.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/care_service.dart';

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
  bool _isHiring = false;

  Future<void> _hireCaregiver() async {
    setState(() {
      _isHiring = true;
    });

    try {
      // For senior citizens, we'll use a placeholder caregiver ID
      // In a real app, this would be passed from the caregiver list
      final response = await CareService.requestCaregiver(
        caregiverId: 5, // Placeholder - in real app this would be dynamic
        message: 'Interested in hiring this caregiver',
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caregiver request sent successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to send request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending request: $e')));
    } finally {
      setState(() {
        _isHiring = false;
      });
    }
  }

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
                  onPressed: _isHiring ? null : _hireCaregiver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5E5C1),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isHiring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow, size: 20),
                  label: Text(
                    _isHiring ? 'Sending Request...' : 'Hire this Caregiver',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

import 'package:flutter/material.dart';
import 'package:second_innings/services/care_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCurrentHiredCaregiverView extends StatefulWidget {
  const ViewCurrentHiredCaregiverView({super.key});

  @override
  State<ViewCurrentHiredCaregiverView> createState() =>
      _ViewCurrentHiredCaregiverViewState();
}

class _ViewCurrentHiredCaregiverViewState
    extends State<ViewCurrentHiredCaregiverView> {
  Map<String, dynamic>? _caregiver;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentCaregiver();
  }

  Future<void> _loadCurrentCaregiver() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await CareService.getCurrentCaregiver();

      if (response.statusCode == 200) {
        final caregiverData = response.data?['data'];
        if (caregiverData != null) {
          setState(() {
            _caregiver = caregiverData;
            _isLoading = false;
          });
        } else {
          setState(() {
            _caregiver = null;
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _caregiver = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load current caregiver';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading current caregiver: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            floating: true,
            title: Text(
              'Hired Caregiver',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!, style: textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCurrentCaregiver,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_caregiver == null)
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No current caregiver',
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have a hired caregiver at the moment',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and basic info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: colorScheme.primaryContainer
                              .withAlpha(204),
                          child: Text(
                            (_caregiver!['full_name'] ?? 'Unknown').isNotEmpty
                                ? (_caregiver!['full_name'] ?? 'Unknown')[0]
                                      .toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _caregiver!['full_name'] ?? 'Unknown',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_caregiver!['age'] != null ||
                                  _caregiver!['gender'] != null) ...[
                                Text(
                                  '${_caregiver!['age'] ?? 'N/A'} • ${_caregiver!['gender'] ?? 'N/A'}',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (_caregiver!['gmail_id'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _caregiver!['gmail_id'],
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description section
                    Text(
                      'About',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _caregiver!['description'] ?? 'No description available',
                      style: textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),

                    // Tags section
                    if (_caregiver!['tags'] != null &&
                        _parseTags(_caregiver!['tags']).isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Specializations',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _parseTags(_caregiver!['tags'])
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: colorScheme.secondaryContainer
                                    .withValues(alpha: 0.3),
                                side: BorderSide(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // Contact section
                    if (_caregiver!['gmail_id'] != null) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _contactCaregiver(_caregiver!['gmail_id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.email, size: 20),
                          label: const Text(
                            'Contact Caregiver',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Parse tags - handle both string and list formats
  List<String> _parseTags(dynamic tagsData) {
    List<String> tags = [];
    if (tagsData != null) {
      if (tagsData is String) {
        // Parse comma-separated string
        tags = tagsData.split(',').map((tag) => tag.trim()).toList();
      } else if (tagsData is List) {
        // Already a list
        tags = tagsData.cast<String>();
      }
    }
    return tags;
  }

  // Open email client with mailto link
  Future<void> _contactCaregiver(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Care Request from Senior Citizen&body=Hello, I would like to get in touch regarding care services.',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email client for: $email'),
            action: SnackBarAction(
              label: 'Copy Email',
              onPressed: () {
                // Show email for manual copying
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Email: $email')));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening email: $e'),
          action: SnackBarAction(
            label: 'Copy Email',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Email: $email')));
            },
          ),
        ),
      );
    }
  }
}

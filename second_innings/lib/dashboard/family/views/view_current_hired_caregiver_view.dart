import 'package:flutter/material.dart';
import 'package:second_innings/services/care_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCurrentHiredCaregiverPage extends StatefulWidget {
  final int seniorCitizenId;
  final Map<String, dynamic> seniorCitizenData;

  const ViewCurrentHiredCaregiverPage({
    super.key,
    required this.seniorCitizenId,
    required this.seniorCitizenData,
  });

  @override
  State<ViewCurrentHiredCaregiverPage> createState() =>
      _ViewCurrentHiredCaregiverPageState();
}

class _ViewCurrentHiredCaregiverPageState
    extends State<ViewCurrentHiredCaregiverPage> {
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
      final response = await CareService.getCurrentCaregiverForSeniorCitizen(
        seniorCitizenId: widget.seniorCitizenId,
      );

      if (response.statusCode == 200) {
        final caregiverData = response.data?['data']?['caregiver'];
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

  Future<void> _launchEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening email: $e')));
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hired Caregiver',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'For: ${widget.seniorCitizenData['full_name'] ?? 'Unknown'}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
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
                    // Senior Citizen Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hired for: ${widget.seniorCitizenData['full_name'] ?? 'Unknown'}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Caregiver Card
                    Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: colorScheme.primaryContainer.withAlpha(51),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer
                                  .withAlpha(204),
                              child: Text(
                                (_caregiver!['full_name'] ?? '?')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
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
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_caregiver!['age'] ?? 'N/A'} • ${_caregiver!['gender'] ?? 'N/A'}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Email section
                                  if (_caregiver!['gmail_id'] != null &&
                                      _caregiver!['gmail_id']
                                          .toString()
                                          .isNotEmpty) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _launchEmail(
                                              _caregiver!['gmail_id'],
                                            ),
                                            child: Text(
                                              _caregiver!['gmail_id'],
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Text(
                                    _caregiver!['description'] ??
                                        'No description available',
                                    style: textTheme.bodyMedium,
                                  ),
                                  if (_caregiver!['tags'] != null) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8.0,
                                      children: _parseTags(_caregiver!['tags'])
                                          .map(
                                            (tag) => Chip(
                                              label: Text(tag),
                                              backgroundColor: colorScheme
                                                  .surface
                                                  .withAlpha(128),
                                              labelStyle: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withAlpha(128),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
}

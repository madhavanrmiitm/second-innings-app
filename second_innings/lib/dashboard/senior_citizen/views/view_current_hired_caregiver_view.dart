import 'package:flutter/material.dart';
import 'package:second_innings/services/care_service.dart';

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
                    Text(
                      _caregiver!['full_name'] ?? 'Unknown',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_caregiver!['age'] ?? 'N/A'} • ${_caregiver!['gender'] ?? 'N/A'}',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _caregiver!['description'] ?? 'No description available',
                      style: textTheme.bodyLarge,
                    ),
                    if (_caregiver!['tags'] != null) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        children: _parseTags(_caregiver!['tags'])
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: colorScheme.surface.withAlpha(
                                  128,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
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

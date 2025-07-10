import 'package:flutter/material.dart';
import 'package:second_innings/services/user_service.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await UserService.fetchUserProfile();
      if (response.statusCode == 200) {
        setState(() {
          _userData = response.data?['data']?['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: textTheme.bodyLarge),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text('No user data available')),
      );
    }

    final userStatus = _userData!['status']?.toString().toLowerCase();
    final isPendingApproval = userStatus == 'pending_approval';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: 'Caregiver Profile'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pending Approval Banner
                  if (isPendingApproval) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.error),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pending_actions,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Profile Under Review',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sent to review for admin. Waiting for approval.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Profile Information
                  _buildProfileCard(context, 'Personal Information', [
                    _buildInfoRow(
                      'Full Name',
                      _userData!['full_name'] ?? 'Not provided',
                    ),
                    _buildInfoRow(
                      'Email',
                      _userData!['gmail_id'] ?? 'Not provided',
                    ),
                    _buildInfoRow(
                      'Date of Birth',
                      _formatDate(_userData!['date_of_birth']),
                    ),
                    _buildInfoRow(
                      'Role',
                      _userData!['role']
                              ?.toString()
                              .replaceAll('_', ' ')
                              .toUpperCase() ??
                          'Not provided',
                    ),
                    _buildInfoRow(
                      'Status',
                      _formatStatus(_userData!['status']),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // YouTube URL (Caregiver specific)
                  if (_userData!['youtube_url'] != null &&
                      _userData!['youtube_url'].toString().isNotEmpty)
                    _buildProfileCard(context, 'Professional Information', [
                      _buildInfoRow(
                        'YouTube Profile',
                        _userData!['youtube_url'] ?? 'Not provided',
                      ),
                    ]),

                  const SizedBox(height: 16),

                  // Description (Caregiver specific)
                  if (_userData!['description'] != null &&
                      _userData!['description'].toString().isNotEmpty)
                    _buildProfileCard(context, 'About Me', [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _userData!['description'] ??
                              'No description provided',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ]),

                  const SizedBox(height: 16),

                  // Tags (Caregiver specific)
                  if (_userData!['tags'] != null &&
                      _userData!['tags'].toString().isNotEmpty)
                    _buildProfileCard(context, 'Skills & Specializations', [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _userData!['tags']
                            .toString()
                            .split(',')
                            .map<Widget>(
                              (tag) => Chip(
                                label: Text(tag.trim()),
                                backgroundColor: colorScheme.primaryContainer,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ]),

                  const SizedBox(height: 24),

                  // Account Information
                  _buildProfileCard(context, 'Account Information', [
                    _buildInfoRow(
                      'Member Since',
                      _formatDate(_userData!['created_at']),
                    ),
                    _buildInfoRow(
                      'Last Updated',
                      _formatDate(_userData!['updated_at']),
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Not provided';
    try {
      final date = DateTime.parse(dateValue.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateValue.toString();
    }
  }

  String _formatStatus(dynamic statusValue) {
    if (statusValue == null) return 'Unknown';
    final status = statusValue.toString().toLowerCase();
    switch (status) {
      case 'pending_approval':
        return 'Pending Approval';
      case 'active':
        return 'Active';
      case 'blocked':
        return 'Blocked';
      default:
        return status.toUpperCase();
    }
  }
}

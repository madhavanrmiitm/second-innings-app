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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: 'My Profile'),
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

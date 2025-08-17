import 'package:flutter/material.dart';
import 'package:second_innings/config/test_mode_config.dart';
import 'package:second_innings/services/user_service.dart';
import 'package:second_innings/dashboard/senior_citizen/senior_citizen_home.dart';
import 'package:second_innings/dashboard/family/family_home.dart';
import 'package:second_innings/dashboard/caregiver/caregiver_home.dart';
import 'package:second_innings/auth/register.dart';

class TestUserSelectionScreen extends StatefulWidget {
  const TestUserSelectionScreen({super.key});

  @override
  State<TestUserSelectionScreen> createState() =>
      _TestUserSelectionScreenState();
}

class _TestUserSelectionScreenState extends State<TestUserSelectionScreen> {
  String _selectedFilter = 'all';
  bool _isLoading = false;

  final Map<String, String> _filterOptions = {
    'all': 'All Users',
    'active': 'Active Users',
    'story': 'Story Characters',
    'admin': 'Administrators',
    'senior_citizen': 'Senior Citizens',
    'family_member': 'Family Members',
    'caregiver': 'Caregivers',
    'interest_group_admin': 'Group Admins',
    'support_user': 'Support Users',
    'unregistered': 'Unregistered',
  };

  List<TestUser> get _filteredUsers {
    switch (_selectedFilter) {
      case 'active':
        return TestModeConfig.getActiveTestUsers();
      case 'story':
        return TestModeConfig.getStoryCharacters();
      case 'admin':
        return TestModeConfig.getAdminUsers();
      case 'support_user':
        return TestModeConfig.getSupportUsers();
      case 'senior_citizen':
      case 'family_member':
      case 'caregiver':
      case 'interest_group_admin':
        return TestModeConfig.getTestUsersByRole(_selectedFilter);
      case 'unregistered':
        return TestModeConfig.getTestUsersByStatus('UNREGISTERED');
      default:
        return TestModeConfig.testUsers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode - Select User'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Users',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.entries.map((entry) {
                      final isSelected = _selectedFilter == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = entry.key;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(TestUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(user.status),
          child: Text(
            user.name.split(' ').map((n) => n[0]).join(''),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (user.isStoryCharacter)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🌟', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            if (user.description != null) ...[
              const SizedBox(height: 4),
              Text(
                user.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (user.age != null) ...[
              const SizedBox(height: 4),
              Text(
                'Age: ${user.age} years',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(user.status),
                const SizedBox(width: 8),
                _buildRoleChip(user.role),
              ],
            ),
          ],
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => _selectTestUser(user),
              ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'ACTIVE':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'PENDING_APPROVAL':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'BLOCKED':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'UNREGISTERED':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getRoleDisplayName(role),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'PENDING_APPROVAL':
        return 'Pending Approval';
      case 'BLOCKED':
        return 'Blocked';
      case 'UNREGISTERED':
        return 'Unregistered';
      default:
        return status;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'caregiver':
        return 'Caregiver';
      case 'family_member':
        return 'Family Member';
      case 'senior_citizen':
        return 'Senior Citizen';
      case 'interest_group_admin':
        return 'Group Admin';
      case 'support_user':
        return 'Support';
      case 'unregistered':
        return 'Unregistered';
      default:
        return role;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING_APPROVAL':
        return Colors.orange;
      case 'BLOCKED':
        return Colors.red;
      case 'UNREGISTERED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectTestUser(TestUser user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (user.isUnregistered) {
        // Navigate to registration screen for unregistered users
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterScreen(
                googleAccountId: user.email,
                idToken: user.token,
                googleDisplayName: user.name,
                isTestMode: true,
              ),
            ),
          );
        }
      } else {
        // Handle existing user authentication
        final authResult = await UserService.handleTestAuthFlow(user);

        if (mounted) {
          if (authResult.isNewUser) {
            // This shouldn't happen for registered test users, but handle it
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterScreen(
                  googleAccountId: user.email,
                  idToken: user.token,
                  googleDisplayName: user.name,
                  isTestMode: true,
                ),
              ),
            );
          } else if (authResult.isExistingUser) {
            // Navigate to appropriate dashboard
            await _navigateToUserDashboard(authResult.userData!);
          } else if (authResult.hasError) {
            _showErrorMessage(authResult.error ?? 'Authentication failed');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to select test user: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToUserDashboard(Map<String, dynamic> userData) async {
    final userName = userData['full_name'] ?? 'User';
    final userType = userData['role']?.toString().toLowerCase();
    final userStatus = userData['status']?.toString().toLowerCase();

    // Check if user is blocked
    if (userStatus == 'blocked') {
      await UserService.clearUserData();
      _showErrorMessage(
        'Your account has been blocked. Please contact support.',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, $userName!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    // Navigate to appropriate dashboard based on user type
    Widget targetScreen;
    switch (userType) {
      case 'senior_citizen':
        targetScreen = const SeniorCitizenHomePage();
        break;
      case 'family_member':
        targetScreen = const FamilyHomePage();
        break;
      case 'caregiver':
        targetScreen = const CaregiverHomePage();
        break;
      case 'admin':
      case 'interest_group_admin':
      case 'support_user':
        // For now, redirect to senior citizen home as default
        // TODO: Create specific dashboards for these roles
        targetScreen = const SeniorCitizenHomePage();
        break;
      default:
        _showErrorMessage('Unknown user type: $userType');
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

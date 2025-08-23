import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/link_new_family_member_page.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/family_service.dart';

class FamilyView extends StatefulWidget {
  const FamilyView({super.key});

  @override
  State<FamilyView> createState() => _FamilyViewState();
}

class _FamilyViewState extends State<FamilyView> {
  List<Map<String, dynamic>> _familyMembers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await FamilyService.getFamilyMembers();

      if (response.statusCode == 200) {
        final membersData = response.data?['data']?['family_members'] as List?;
        if (membersData != null) {
          setState(() {
            _familyMembers = membersData.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _familyMembers = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load family members';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading family members: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFamilyMember(
    String memberUserId,
    String memberFirebaseUid,
  ) async {
    try {
      print(
        'Deleting family member - User ID: $memberUserId, Firebase UID: $memberFirebaseUid',
      ); // Debug log
      final response = await FamilyService.deleteFamilyMember(
        memberUserId,
        memberFirebaseUid,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member removed successfully')),
        );
        // Reload family members to reflect the change
        await _loadFamilyMembers();
      } else {
        print(
          'Delete failed with status: ${response.statusCode}, error: ${response.error}',
        ); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to remove family member'),
          ),
        );
      }
    } catch (e) {
      print('Delete error: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing family member: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: 'Family'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Family",
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _loadFamilyMembers,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh Family Members',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LinkNewFamilyMemberPage(),
                                ),
                              );
                              // Reload family members if a new member was added
                              if (result == true) {
                                await _loadFamilyMembers();
                              }
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Member'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
                      onPressed: _loadFamilyMembers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _buildFamilyMembersList(colorScheme, textTheme),
            ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_familyMembers.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.family_restroom, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No family members linked yet',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add family members to stay connected',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: _familyMembers.length,
      itemBuilder: (context, index) {
        final member = _familyMembers[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer.withAlpha(204),
                  child: Icon(
                    Icons.person_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['full_name'] ?? 'Unknown',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member['relationship'] ?? 'Family Member',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      if (member['email'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          member['email'],
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                      // Debug: Show available fields
                      if (member['firebase_uid'] != null ||
                          member['id'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${member['id']} | UID: ${member['firebase_uid'] ?? 'N/A'}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Family Member'),
                        content: Text(
                          'Are you sure you want to remove ${member['full_name'] ?? 'this family member'}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // URL needs member's user ID, body needs Firebase UID
                              final memberUserId =
                                  member['id']?.toString() ?? '';
                              final memberFirebaseUid =
                                  member['firebase_uid']?.toString() ??
                                  member['id']?.toString() ??
                                  '';

                              if (memberUserId.isNotEmpty &&
                                  memberFirebaseUid.isNotEmpty) {
                                _deleteFamilyMember(
                                  memberUserId,
                                  memberFirebaseUid,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Missing member information for deletion',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.error,
                            ),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

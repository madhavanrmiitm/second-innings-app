import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/create_new_local_group_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/local_groups_details.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/interest_group_service.dart';
import 'package:second_innings/services/user_service.dart';
import 'package:second_innings/services/api_service.dart';

class LocalGroupsView extends StatefulWidget {
  const LocalGroupsView({super.key});

  @override
  State<LocalGroupsView> createState() => _LocalGroupsViewState();
}

class _LocalGroupsViewState extends State<LocalGroupsView> {
  List<Map<String, dynamic>> _interestGroups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInterestGroups();
  }

  Future<void> _loadInterestGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await InterestGroupService.getInterestGroups();

      if (response.statusCode == 200) {
        final groupsData = response.data?['data']?['interest_groups'] as List?;
        if (groupsData != null) {
          setState(() {
            _interestGroups = groupsData.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _interestGroups = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load interest groups';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading interest groups: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      final response = await InterestGroupService.joinGroup(groupId: groupId);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the group')),
        );
        // Reload groups to reflect the change
        await _loadInterestGroups();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to join group')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error joining group: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: 'Local Groups'),
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
                        "Interest Groups",
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateNewLocalGroupView(),
                            ),
                          );
                          // Reload groups if a new group was created
                          if (result == true) {
                            await _loadInterestGroups();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Group'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
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
                      onPressed: _loadInterestGroups,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _buildGroupsList(colorScheme, textTheme),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_interestGroups.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.groups_outlined, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No interest groups available',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new group or check back later',
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
      itemCount: _interestGroups.length,
      itemBuilder: (context, index) {
        final group = _interestGroups[index];
        final isActive = group['is_active'] == true;
        final isMember = group['is_member'] == true;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorScheme.primaryContainer.withAlpha(51),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalGroupDetailsView(group: group),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group['name'] ?? 'Untitled Group',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'INACTIVE',
                          style: textTheme.bodySmall?.copyWith(
                            color: isActive
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group['description'] ?? 'No description available',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (group['location'] != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          group['location'],
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (group['timing'] != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          group['timing'],
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!isMember && isActive)
                    ElevatedButton(
                      onPressed: () => _joinGroup(group['id'].toString()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text('Join Group'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

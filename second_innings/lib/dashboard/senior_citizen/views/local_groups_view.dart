import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/create_new_local_group_view.dart';
import 'package:second_innings/dashboard/senior_citizen/views/local_groups_details.dart';
import 'package:second_innings/dashboard/senior_citizen/views/my_local_groups_view.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/interest_group_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalGroupsView extends StatefulWidget {
  const LocalGroupsView({super.key});

  @override
  State<LocalGroupsView> createState() => _LocalGroupsViewState();
}

class _LocalGroupsViewState extends State<LocalGroupsView> {
  List<Map<String, dynamic>> _interestGroups = [];
  List<Map<String, dynamic>> _myGroups = [];
  bool _isLoading = true;
  bool _isLoadingMyGroups = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInterestGroups();
    _loadMyGroups();
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

  Future<void> _loadMyGroups() async {
    setState(() {
      _isLoadingMyGroups = true;
    });

    try {
      final response = await InterestGroupService.getMyGroups();

      if (response.statusCode == 200) {
        final groupsData = response.data?['data']?['groups'] as List?;
        if (groupsData != null) {
          setState(() {
            _myGroups = groupsData.cast<Map<String, dynamic>>();
            _isLoadingMyGroups = false;
          });
        } else {
          setState(() {
            _myGroups = [];
            _isLoadingMyGroups = false;
          });
        }
      } else {
        setState(() {
          _myGroups = [];
          _isLoadingMyGroups = false;
        });
      }
    } catch (e) {
      setState(() {
        _myGroups = [];
        _isLoadingMyGroups = false;
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
        // Reload both lists to reflect the change
        await _loadInterestGroups();
        await _loadMyGroups();
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

  Future<void> _launchWhatsAppLink(String whatsappLink) async {
    try {
      final Uri url = Uri.parse(whatsappLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp link')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening WhatsApp link: $e')),
      );
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'No timing specified';

    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} on ${dateTime.day}/${dateTime.month}/${dateTime.year} (in ${difference.inDays} days)';
      } else if (difference.inHours > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} on ${dateTime.day}/${dateTime.month}/${dateTime.year} (in ${difference.inHours} hours)';
      } else if (difference.inMinutes > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} on ${dateTime.day}/${dateTime.month}/${dateTime.year} (in ${difference.inMinutes} minutes)';
      } else {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} on ${dateTime.day}/${dateTime.month}/${dateTime.year} (now)';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatCreationDate(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';

    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  bool _isUserMember(String groupId) {
    return _myGroups.any((group) => group['id'].toString() == groupId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNewLocalGroupView(),
            ),
          );
          // Reload groups if a new group was created
          if (result == true) {
            await _loadInterestGroups();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              // Show loading indicator
                              setState(() {
                                _isLoading = true;
                                _isLoadingMyGroups = true;
                              });
                              // Refresh both lists
                              await Future.wait([
                                _loadInterestGroups(),
                                _loadMyGroups(),
                              ]);
                            },
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh Groups',
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MyLocalGroupsView(),
                                ),
                              );
                              // Reload groups when returning to refresh join status
                              await _loadInterestGroups();
                              await _loadMyGroups();
                            },
                            icon: const Icon(Icons.group),
                            label: const Text('My Groups'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
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
        final isActive = group['status'] == 'active';
        final isMember = _isUserMember(group['id'].toString());

        // Format the timing using helper method
        final formattedTiming = _formatDateTime(group['timing']);

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
                          group['title'] ?? 'Untitled Group',
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
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'INACTIVE',
                          style: textTheme.bodySmall?.copyWith(
                            color: isActive
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category badge
                  if (group['category'] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        group['category'],
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    group['description'] ?? 'No description available',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  // Timing information
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedTiming,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Member count
                  if (group['member_count'] != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group['member_count']} members',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // WhatsApp link
                  if (group['whatsapp_link'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.message, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                _launchWhatsAppLink(group['whatsapp_link']),
                            child: Text(
                              'Join WhatsApp Group',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Creation date
                  if (group['created_at'] != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Created: ${_formatCreationDate(group['created_at'])}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Action buttons
                  if (isActive) ...[
                    Row(
                      children: [
                        if (!isMember) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _joinGroup(group['id'].toString());
                                // Reload both lists to update membership status
                                await _loadMyGroups();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              child: const Text('Join Group'),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                // Navigate to My Groups to leave
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MyLocalGroupsView(),
                                  ),
                                );
                                // Reload both lists when returning
                                await _loadInterestGroups();
                                await _loadMyGroups();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: colorScheme.primary),
                              ),
                              child: const Text('View in My Groups'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

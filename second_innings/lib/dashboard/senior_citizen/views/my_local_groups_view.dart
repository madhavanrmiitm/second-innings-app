import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/local_groups_details.dart';
import 'package:second_innings/dashboard/senior_citizen/views/edit_local_group_view.dart';
import 'package:second_innings/services/interest_group_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MyLocalGroupsView extends StatefulWidget {
  const MyLocalGroupsView({super.key});

  @override
  State<MyLocalGroupsView> createState() => _MyLocalGroupsViewState();
}

class _MyLocalGroupsViewState extends State<MyLocalGroupsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _myGroups = [];
  List<Map<String, dynamic>> _myCreatedGroups = [];
  bool _isLoadingMyGroups = true;
  bool _isLoadingCreatedGroups = true;
  String? _errorMyGroups;
  String? _errorCreatedGroups;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyGroups();
    _loadMyCreatedGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _leaveGroup(String groupId) async {
    try {
      final response = await InterestGroupService.leaveGroup(groupId: groupId);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the group')),
        );
        // Reload groups to reflect the change
        await _loadMyGroups();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to leave group')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error leaving group: $e')));
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
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} on ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatJoinedDate(String? dateTimeString) {
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

  String _formatCreatedDate(String? dateTimeString) {
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

  Future<void> _loadMyGroups() async {
    setState(() {
      _isLoadingMyGroups = true;
      _errorMyGroups = null;
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
          _errorMyGroups = response.error ?? 'Failed to load my groups';
          _isLoadingMyGroups = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMyGroups = 'Error loading my groups: $e';
        _isLoadingMyGroups = false;
      });
    }
  }

  Future<void> _loadMyCreatedGroups() async {
    setState(() {
      _isLoadingCreatedGroups = true;
      _errorCreatedGroups = null;
    });

    try {
      final response = await InterestGroupService.getMyCreatedGroups();

      if (response.statusCode == 200) {
        final groupsData = response.data?['data']?['groups'] as List?;
        if (groupsData != null) {
          setState(() {
            _myCreatedGroups = groupsData.cast<Map<String, dynamic>>();
            _isLoadingCreatedGroups = false;
          });
        } else {
          setState(() {
            _myCreatedGroups = [];
            _isLoadingCreatedGroups = false;
          });
        }
      } else {
        setState(() {
          _errorCreatedGroups =
              response.error ?? 'Failed to load created groups';
          _isLoadingCreatedGroups = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorCreatedGroups = 'Error loading created groups: $e';
        _isLoadingCreatedGroups = false;
      });
    }
  }

  Widget _buildGroupCard(Map<String, dynamic> group, bool isCreatedByMe) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = group['status'] ?? 'active';
    final isActive = status == 'active';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      group['title'] ?? 'Unknown Group',
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
                      color: isActive ? colorScheme.primary : colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.onError,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Group details row
              Row(
                children: [
                  if (group['timing'] != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDateTime(group['timing']),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Member count and date
              Row(
                children: [
                  if (group['member_count'] != null) ...[
                    Icon(Icons.people, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${group['member_count']} members',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCreatedByMe
                        ? 'Created ${_formatCreatedDate(group['created_at'])}'
                        : 'Joined ${_formatJoinedDate(group['joined_at'])}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  if (group['whatsapp_link'] != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _launchWhatsAppLink(group['whatsapp_link']),
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('WhatsApp'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (!isCreatedByMe) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _leaveGroup(group['id'].toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                        child: const Text('Leave Group'),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditLocalGroupView(group: group),
                            ),
                          ).then((_) {
                            _loadMyCreatedGroups();
                          });
                        },
                        child: const Text('Edit Group'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    if (tabIndex == 0) {
      // Groups I am part of
      if (_isLoadingMyGroups) {
        return const Center(child: CircularProgressIndicator());
      } else if (_errorMyGroups != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_errorMyGroups!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMyGroups,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      } else if (_myGroups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'You haven\'t joined any groups yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      } else {
        return ListView.builder(
          itemCount: _myGroups.length,
          itemBuilder: (context, index) =>
              _buildGroupCard(_myGroups[index], false),
        );
      }
    } else {
      // Groups created by me
      if (_isLoadingCreatedGroups) {
        return const Center(child: CircularProgressIndicator());
      } else if (_errorCreatedGroups != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_errorCreatedGroups!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMyCreatedGroups,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      } else if (_myCreatedGroups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.create_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'You haven\'t created any groups yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      } else {
        return ListView.builder(
          itemCount: _myCreatedGroups.length,
          itemBuilder: (context, index) =>
              _buildGroupCard(_myCreatedGroups[index], true),
        );
      }
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
          SliverAppBar.large(
            pinned: true,
            floating: true,
            title: Text(
              'My Local Groups',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colorScheme.primaryContainer.withAlpha(204),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (_tabController.index == 0) {
                    _loadMyGroups();
                  } else {
                    _loadMyCreatedGroups();
                  }
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.group), text: 'Groups I am part of'),
                  Tab(icon: Icon(Icons.create), text: 'Groups created by me'),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicator: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildTabContent(0), _buildTabContent(1)],
            ),
          ),
        ],
      ),
    );
  }
}

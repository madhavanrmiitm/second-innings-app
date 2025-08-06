import 'package:flutter/material.dart';
import 'package:second_innings/dashboard/senior_citizen/views/edit_local_group_view.dart';
import 'package:second_innings/services/interest_group_service.dart';

class MyLocalGroupsView extends StatefulWidget {
  const MyLocalGroupsView({super.key});

  @override
  State<MyLocalGroupsView> createState() => _MyLocalGroupsViewState();
}

class _MyLocalGroupsViewState extends State<MyLocalGroupsView> {
  List<Map<String, dynamic>> _myGroups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyGroups();
  }

  Future<void> _loadMyGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await InterestGroupService.getInterestGroups();

      if (response.statusCode == 200) {
        final groupsData = response.data?['data']?['interest_groups'] as List?;
        if (groupsData != null) {
          // Filter groups created by the current user
          final myGroups = groupsData.cast<Map<String, dynamic>>().where((
            group,
          ) {
            // For now, we'll show all groups. In a real app, you'd filter by created_by
            return true;
          }).toList();

          setState(() {
            _myGroups = myGroups;
            _isLoading = false;
          });
        } else {
          setState(() {
            _myGroups = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load my groups';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading my groups: $e';
        _isLoading = false;
      });
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
              'My Created Groups',
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
                      onPressed: _loadMyGroups,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: _myGroups.length,
              itemBuilder: (context, index) {
                final group = _myGroups[index];
                final status = group['status'] ?? 'active';
                final color = status == 'active'
                    ? colorScheme.primary
                    : status == 'inactive'
                    ? colorScheme.error
                    : colorScheme.secondary;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: colorScheme.primaryContainer.withAlpha(51),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    title: Text(
                      group['title'] ?? 'Unknown Group',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Status: $status',
                      style: textTheme.bodyMedium?.copyWith(color: color),
                    ),
                    trailing: status == 'active'
                        ? IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditLocalGroupView(
                                    groupId: group['id'].toString(),
                                    groupData: group,
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

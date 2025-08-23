import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:second_innings/services/interest_group_service.dart';

class LocalGroupDetailsView extends StatefulWidget {
  final Map<String, dynamic> group;

  const LocalGroupDetailsView({required this.group, super.key});

  @override
  State<LocalGroupDetailsView> createState() => _LocalGroupDetailsViewState();
}

class _LocalGroupDetailsViewState extends State<LocalGroupDetailsView> {
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
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

  Future<void> _joinGroup(BuildContext context) async {
    try {
      final response = await InterestGroupService.joinGroup(
        groupId: widget.group['id'].toString(),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully joined the group')),
          );
          // Pop back to refresh the view
          Navigator.pop(context, true);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Failed to join group')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error joining group: $e')));
      }
    }
  }

  Future<void> _leaveGroup(BuildContext context) async {
    try {
      final response = await InterestGroupService.leaveGroup(
        groupId: widget.group['id'].toString(),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the group')),
          );
          // Pop back to refresh the view
          Navigator.pop(context, true);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Failed to leave group')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error leaving group: $e')));
      }
    }
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Group'),
          content: const Text('Are you sure you want to leave this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _leaveGroup(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Extract data from group
    final title = widget.group['title']?.toString() ?? 'Untitled Group';
    final description =
        widget.group['description']?.toString() ?? 'No description available';
    final category = widget.group['category']?.toString();
    final status = widget.group['status']?.toString();
    final timing = widget.group['timing']?.toString();
    final memberCount = widget.group['member_count'];
    final whatsappLink = widget.group['whatsapp_link']?.toString();
    final createdAt = widget.group['created_at']?.toString();
    final joinedAt = widget.group['joined_at']?.toString();
    final isActive = status == 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.primaryContainer.withAlpha(204),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 16),

            // Category badge
            if (category != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description card
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: .5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Group details section
            Text(
              'Group Details',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Details grid
            Column(
              children: [
                // Timing
                if (timing != null) ...[
                  _buildDetailRow(
                    context,
                    Icons.access_time,
                    'Meeting Time',
                    _formatDateTime(timing),
                    colorScheme,
                    textTheme,
                  ),
                  const SizedBox(height: 16),
                ],

                // Member count
                if (memberCount != null) ...[
                  _buildDetailRow(
                    context,
                    Icons.people,
                    'Members',
                    '$memberCount members',
                    colorScheme,
                    textTheme,
                  ),
                  const SizedBox(height: 16),
                ],

                // Creation date
                if (createdAt != null) ...[
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Created',
                    _formatCreationDate(createdAt),
                    colorScheme,
                    textTheme,
                  ),
                  const SizedBox(height: 16),
                ],

                // Joined date (if user is a member)
                if (joinedAt != null) ...[
                  _buildDetailRow(
                    context,
                    Icons.person_add,
                    'Joined',
                    _formatJoinedDate(joinedAt),
                    colorScheme,
                    textTheme,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                // WhatsApp join button
                if (whatsappLink != null && whatsappLink.isNotEmpty) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(context, whatsappLink),
                      icon: const Icon(Icons.message),
                      label: const Text('Join WhatsApp Group'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Leave group button (if user is a member)
                if (joinedAt != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showLeaveGroupDialog(context),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Leave Group'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.titleMedium,
                      ),
                    ),
                  ),
                ] else ...[
                  // Join group button (if user is not a member)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _joinGroup(context),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join Group'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

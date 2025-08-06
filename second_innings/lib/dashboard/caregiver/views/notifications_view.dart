import 'package:flutter/material.dart';
import 'package:second_innings/services/notification_service.dart';
import 'package:second_innings/widgets/user_app_bar.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await NotificationService.getNotifications();

      if (response.statusCode == 200) {
        final notifications =
            response.data?['data']?['notifications'] as List<dynamic>?;
        setState(() {
          _notifications = notifications?.cast<Map<String, dynamic>>() ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = response.error ?? 'Failed to fetch notifications';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final response = await NotificationService.markAsRead(
        notificationId: notificationId,
      );

      if (response.statusCode == 200) {
        // Reload notifications to reflect the change
        await _fetchNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error ?? 'Failed to mark as read')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error marking as read: $e')));
    }
  }

  String _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return '📋';
      case 'care_request':
        return '🩺';
      case 'interest_group':
        return '👥';
      case 'support_ticket':
        return '🎫';
      case 'relation':
        return '👨‍👩‍👧‍👦';
      default:
        return '🔔';
    }
  }

  Color _getPriorityColor(String priority, ColorScheme colorScheme) {
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.primary;
      case 'low':
        return colorScheme.outline;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const UserAppBar(title: 'Notifications'),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    _error!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            )
          else if (_notifications.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['is_read'] == true;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: isRead
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primaryContainer.withAlpha(100),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      leading: Text(
                        _getNotificationIcon(notification['type'] ?? 'general'),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        notification['title'] ?? 'Untitled Notification',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notification['message'] != null)
                            Text(
                              notification['message'],
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (notification['created_at'] != null)
                            Text(
                              '${notification['created_at']}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: !isRead
                          ? IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () =>
                                  _markAsRead(notification['id'].toString()),
                              tooltip: 'Mark as Read',
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

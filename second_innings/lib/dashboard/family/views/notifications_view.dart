import 'package:flutter/material.dart';
import 'package:second_innings/widgets/user_app_bar.dart';
import 'package:second_innings/services/notification_service.dart';
import 'package:second_innings/services/user_service.dart';
import 'package:second_innings/services/api_service.dart';

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

  Future<void> _refreshNotifications() async {
    await _fetchNotifications();
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
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              title: const Text('Notifications'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshNotifications,
                  tooltip: 'Refresh Notifications',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      "Notifications",
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Stay updated with important updates and alerts",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: _buildNotificationsList(colorScheme, textTheme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_notifications.isEmpty) {
      return SliverToBoxAdapter(
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
              const SizedBox(height: 8),
              Text(
                'You\'re all caught up!',
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
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isRead = notification['is_read'] == true;
        final type = notification['type'] ?? 'general';
        final priority = notification['priority'] ?? 'medium';
        final title = notification['title'] ?? 'Notification';
        final message = notification['message'] ?? 'No message';
        final timestamp = notification['created_at'] ?? '';

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
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getNotificationIcon(type),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          priority,
                          colorScheme,
                        ).withAlpha(100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(priority, colorScheme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timestamp,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: !isRead
                ? IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    onPressed: () => _markAsRead(notification['id'].toString()),
                    tooltip: 'Mark as Read',
                  )
                : null,
          ),
        );
      },
    );
  }
}

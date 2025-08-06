import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class NotificationService {
  // Get all notifications for the current user
  static Future<ApiResponse<Map<String, dynamic>>> getNotifications() async {
    return await ApiService.get('/api/notifications');
  }

  // Mark a notification as read
  static Future<ApiResponse<Map<String, dynamic>>> markAsRead({
    required String notificationId,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    return await ApiService.post(
      '/api/notifications/$notificationId/read',
      body: {'id_token': idToken},
    );
  }
}

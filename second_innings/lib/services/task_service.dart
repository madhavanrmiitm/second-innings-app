import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class TaskService {
  // Get all tasks for the current user
  static Future<ApiResponse<Map<String, dynamic>>> getTasks() async {
    return await ApiService.get('/api/tasks');
  }

  // Get a specific task by ID
  static Future<ApiResponse<Map<String, dynamic>>> getTask(
    String taskId,
  ) async {
    return await ApiService.get('/api/tasks/$taskId');
  }

  // Create a new task
  static Future<ApiResponse<Map<String, dynamic>>> createTask({
    required String title,
    required String description,
    String? timeOfCompletion,
    String? assignedToFirebaseUid,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {
      'id_token': idToken,
      'title': title,
      'description': description,
    };

    if (timeOfCompletion != null) body['time_of_completion'] = timeOfCompletion;
    if (assignedToFirebaseUid != null) {
      body['assigned_to_firebase_uid'] = assignedToFirebaseUid;
    }

    return await ApiService.post('/api/tasks', body: body);
  }

  // Update a task
  static Future<ApiResponse<Map<String, dynamic>>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? timeOfCompletion,
    String? assignedToFirebaseUid,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (timeOfCompletion != null) body['time_of_completion'] = timeOfCompletion;
    if (assignedToFirebaseUid != null) {
      body['assigned_to_firebase_uid'] = assignedToFirebaseUid;
    }

    return await ApiService.put('/api/tasks/$taskId', body: body);
  }

  // Complete a task
  static Future<ApiResponse<Map<String, dynamic>>> completeTask({
    required String taskId,
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
      '/api/tasks/$taskId/complete',
      body: {'id_token': idToken},
    );
  }

  // Delete a task
  static Future<ApiResponse<Map<String, dynamic>>> deleteTask(
    String taskId,
  ) async {
    return await ApiService.delete('/api/tasks/$taskId');
  }

  // Get all reminders
  static Future<ApiResponse<Map<String, dynamic>>> getReminders() async {
    return await ApiService.get('/api/reminders');
  }

  // Create a new reminder
  static Future<ApiResponse<Map<String, dynamic>>> createReminder({
    required String title,
    required String description,
    required String reminderTime,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {
      'id_token': idToken,
      'title': title,
      'description': description,
      'reminder_time': reminderTime,
    };

    return await ApiService.post('/api/reminders', body: body);
  }

  // Update a reminder
  static Future<ApiResponse<Map<String, dynamic>>> updateReminder({
    required String reminderId,
    String? title,
    String? description,
    String? reminderTime,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (reminderTime != null) body['reminder_time'] = reminderTime;

    return await ApiService.put('/api/reminders/$reminderId', body: body);
  }

  // Snooze a reminder
  static Future<ApiResponse<Map<String, dynamic>>> snoozeReminder({
    required String reminderId,
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
      '/api/reminders/$reminderId/snooze',
      body: {'id_token': idToken},
    );
  }

  // Cancel a reminder
  static Future<ApiResponse<Map<String, dynamic>>> cancelReminder(
    String reminderId,
  ) async {
    return await ApiService.delete('/api/reminders/$reminderId');
  }
}

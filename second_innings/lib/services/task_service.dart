import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class TaskService {
  // Get all tasks for the current user (including linked senior citizen tasks for family members)
  static Future<ApiResponse<Map<String, dynamic>>> getTasks({
    String? seniorCitizenId,
  }) async {
    String endpoint = '/api/tasks';
    if (seniorCitizenId != null) {
      endpoint += '?senior_citizen_id=$seniorCitizenId';
    }
    return await ApiService.get(endpoint);
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

  // Create a new task using AI mode with prompt
  static Future<ApiResponse<Map<String, dynamic>>> createTaskWithAI({
    required String aiPrompt,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken, 'ai_mode': true, 'ai_prompt': aiPrompt};

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

    final Map<String, dynamic> body = {'id_token': idToken};

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
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    return await ApiService.delete(
      '/api/tasks/$taskId',
      body: {'id_token': idToken},
    );
  }
}

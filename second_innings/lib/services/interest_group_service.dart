import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class InterestGroupService {
  // Get all interest groups
  static Future<ApiResponse<Map<String, dynamic>>> getInterestGroups() async {
    return await ApiService.get('/api/interest-groups');
  }

  // Create a new interest group
  static Future<ApiResponse<Map<String, dynamic>>> createInterestGroup({
    required String title,
    required String description,
    String? location,
    String? timing,
    String? links,
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

    if (location != null) body['location'] = location;
    if (timing != null) body['timing'] = timing;
    if (links != null) body['links'] = links;

    return await ApiService.post('/api/interest-groups', body: body);
  }

  // Update an interest group
  static Future<ApiResponse<Map<String, dynamic>>> updateInterestGroup({
    required String groupId,
    String? title,
    String? description,
    String? location,
    String? timing,
    String? links,
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
    if (location != null) body['location'] = location;
    if (timing != null) body['timing'] = timing;
    if (links != null) body['links'] = links;

    return await ApiService.put('/api/interest-groups/$groupId', body: body);
  }

  // Join an interest group
  static Future<ApiResponse<Map<String, dynamic>>> joinGroup({
    required String groupId,
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
      '/api/interest-groups/$groupId/join',
      body: {'id_token': idToken},
    );
  }

  // Leave an interest group
  static Future<ApiResponse<Map<String, dynamic>>> leaveGroup({
    required String groupId,
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
      '/api/interest-groups/$groupId/leave',
      body: {'id_token': idToken},
    );
  }
}

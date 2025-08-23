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
    String? whatsappLink,
    String? category,
    String? timing,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'title': title, 'description': description};

    if (whatsappLink != null && whatsappLink.isNotEmpty) {
      body['whatsapp_link'] = whatsappLink;
    }
    if (category != null && category.isNotEmpty) {
      body['category'] = category;
    }
    if (timing != null && timing.isNotEmpty) {
      body['timing'] = timing;
    }

    return await ApiService.post('/api/interest-groups', body: body);
  }

  // Update an interest group
  static Future<ApiResponse<Map<String, dynamic>>> updateInterestGroup({
    required String groupId,
    String? title,
    String? description,
    String? whatsappLink,
    String? category,
    String? status,
    String? timing,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final Map<String, dynamic> body = {};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (whatsappLink != null) body['whatsapp_link'] = whatsappLink;
    if (category != null) body['category'] = category;
    if (status != null) body['status'] = status;
    if (timing != null) body['timing'] = timing;

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

    return await ApiService.delete(
      '/api/interest-groups/$groupId/leave',
      body: {'id_token': idToken},
    );
  }

  // Get groups that the current user has joined
  static Future<ApiResponse<Map<String, dynamic>>> getMyGroups() async {
    return await ApiService.get('/api/interest-group/my-groups');
  }

  // Get groups that the current user has created
  static Future<ApiResponse<Map<String, dynamic>>> getMyCreatedGroups() async {
    return await ApiService.get('/api/interest-group/my-created-groups');
  }
}

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class TicketService {
  // Get all tickets for the current user
  static Future<ApiResponse<Map<String, dynamic>>> getUserTickets() async {
    return await ApiService.get('/api/tickets');
  }

  // Create a new support ticket
  static Future<ApiResponse<Map<String, dynamic>>> createTicket({
    required String subject,
    required String description,
    String? priority,
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
      'subject': subject,
      'description': description,
    };

    if (priority != null) {
      body['priority'] = priority;
    }

    return await ApiService.post('/api/tickets', body: body);
  }

  // Update a ticket
  static Future<ApiResponse<Map<String, dynamic>>> updateTicket({
    required String ticketId,
    String? subject,
    String? description,
    String? priority,
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

    if (subject != null) body['subject'] = subject;
    if (description != null) body['description'] = description;
    if (priority != null) body['priority'] = priority;

    return await ApiService.put('/api/tickets/$ticketId', body: body);
  }
}

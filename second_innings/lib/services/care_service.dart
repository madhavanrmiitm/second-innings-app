import 'api_service.dart';
import 'api_response.dart';

class CareService {
  // Get all available caregivers
  static Future<ApiResponse<Map<String, dynamic>>> getCaregivers() async {
    return await ApiService.get('/api/caregivers');
  }

  // Get a specific caregiver profile
  static Future<ApiResponse<Map<String, dynamic>>> getCaregiverProfile(
    String caregiverId,
  ) async {
    return await ApiService.get('/api/caregivers/$caregiverId');
  }

  // Get all care requests
  static Future<ApiResponse<Map<String, dynamic>>> getCareRequests() async {
    return await ApiService.get('/api/care-requests');
  }

  // Get a specific care request
  static Future<ApiResponse<Map<String, dynamic>>> getCareRequest(
    String requestId,
  ) async {
    return await ApiService.get('/api/care-requests/$requestId');
  }

  // Create a new care request
  static Future<ApiResponse<Map<String, dynamic>>> createCareRequest({
    required String title,
    required String description,
    required String location,
    required String timing,
    String? budget,
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
      'location': location,
      'timing': timing,
    };

    if (budget != null) {
      body['budget'] = budget;
    }

    return await ApiService.post('/api/care-requests', body: body);
  }

  // Update a care request
  static Future<ApiResponse<Map<String, dynamic>>> updateCareRequest({
    required String requestId,
    String? title,
    String? description,
    String? location,
    String? timing,
    String? budget,
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
    if (budget != null) body['budget'] = budget;

    return await ApiService.put('/api/care-requests/$requestId', body: body);
  }

  // Close a care request
  static Future<ApiResponse<Map<String, dynamic>>> closeCareRequest({
    required String requestId,
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
      '/api/care-requests/$requestId/close',
      body: {'id_token': idToken},
    );
  }

  // Apply for a care request (for caregivers)
  static Future<ApiResponse<Map<String, dynamic>>> applyForRequest({
    required String requestId,
    String? message,
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

    if (message != null) {
      body['message'] = message;
    }

    return await ApiService.post(
      '/api/caregivers/requests/$requestId/apply',
      body: body,
    );
  }

  // Accept an engagement (for family members)
  static Future<ApiResponse<Map<String, dynamic>>> acceptEngagement({
    required String requestId,
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
      '/api/caregivers/engagements/$requestId/accept',
      body: {'id_token': idToken},
    );
  }

  // Decline an engagement (for family members)
  static Future<ApiResponse<Map<String, dynamic>>> declineEngagement({
    required String requestId,
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
      '/api/caregivers/engagements/$requestId/decline',
      body: {'id_token': idToken},
    );
  }

  // Get caregiver requests (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>>
  getCaregiverRequests() async {
    return await ApiService.get('/api/me/caregiver-requests');
  }

  // Request a caregiver (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>> requestCaregiver({
    required int caregiverId,
    String? message,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken, 'caregiver_id': caregiverId};

    if (message != null) body['message'] = message;

    return await ApiService.post('/api/me/request-caregiver', body: body);
  }

  // Accept a caregiver request (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>> acceptCaregiverRequest({
    required int requestId,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken, 'request_id': requestId};

    return await ApiService.post(
      '/api/me/accept-caregiver-request',
      body: body,
    );
  }

  // Reject a caregiver request (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>> rejectCaregiverRequest({
    required int requestId,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken, 'request_id': requestId};

    return await ApiService.post(
      '/api/me/reject-caregiver-request',
      body: body,
    );
  }

  // Cancel a caregiver request (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>> cancelCaregiverRequest({
    required int requestId,
  }) async {
    // Get the stored ID token
    final idToken = await ApiService.getIdToken();
    if (idToken == null) {
      return ApiResponse<Map<String, dynamic>>(
        statusCode: 401,
        error: 'Authentication token not found',
      );
    }

    final body = {'id_token': idToken, 'request_id': requestId};

    return await ApiService.post(
      '/api/me/cancel-caregiver-request',
      body: body,
    );
  }

  // Close a caregiver request (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>> closeCaregiverRequest({
    required int requestId,
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
      '/api/care-requests/$requestId/close',
      body: {'id_token': idToken},
    );
  }

  // Get current hired caregiver (for family members and senior citizens)
  static Future<ApiResponse<Map<String, dynamic>>> getCurrentCaregiver() async {
    return await ApiService.get('/api/me/current-caregiver');
  }

  // Get caregivers for a specific senior citizen (for family members)
  static Future<ApiResponse<Map<String, dynamic>>>
  getCaregiversForSeniorCitizen({required int seniorCitizenId}) async {
    return await ApiService.get(
      '/api/senior-citizens/$seniorCitizenId/caregivers',
    );
  }

  // Get current hired caregiver for a specific senior citizen (for family members)
  static Future<ApiResponse<Map<String, dynamic>>>
  getCurrentCaregiverForSeniorCitizen({required int seniorCitizenId}) async {
    return await ApiService.get(
      '/api/senior-citizens/$seniorCitizenId/current-caregiver',
    );
  }

  // Get caregiver requests for a specific senior citizen (for family members)
  static Future<ApiResponse<Map<String, dynamic>>>
  getCaregiverRequestsForSeniorCitizen({required int seniorCitizenId}) async {
    return await ApiService.get(
      '/api/senior-citizens/$seniorCitizenId/caregiver-requests',
    );
  }

  // Request a caregiver for a specific senior citizen (for family members)
  static Future<ApiResponse<Map<String, dynamic>>>
  requestCaregiverForSeniorCitizen({
    required int seniorCitizenId,
    required int caregiverId,
    String? message,
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
      'senior_citizen_id': seniorCitizenId,
      'caregiver_id': caregiverId,
    };

    if (message != null) body['message'] = message;

    return await ApiService.post(
      '/api/senior-citizens/$seniorCitizenId/request-caregiver',
      body: body,
    );
  }
}

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'api_response.dart';
import '../config/api_config.dart';

class FamilyService {
  // Get all family members for the current senior citizen
  static Future<ApiResponse<Map<String, dynamic>>> getFamilyMembers() async {
    return await ApiService.get('/api/senior-citizens/me/family-members');
  }

  // Add a new family member
  static Future<ApiResponse<Map<String, dynamic>>> addFamilyMember({
    required String familyMemberFirebaseUid,
    required String relationship,
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
      'family_member_firebase_uid': familyMemberFirebaseUid,
      'relationship': relationship,
    };

    return await ApiService.post(
      '/api/senior-citizens/me/family-members',
      body: body,
    );
  }

  // Delete a family member
  static Future<ApiResponse<Map<String, dynamic>>> deleteFamilyMember(
    String memberId,
  ) async {
    return await ApiService.delete(
      '/api/senior-citizens/me/family-members/$memberId',
    );
  }

  // Get linked senior citizens (for family members)
  static Future<ApiResponse<Map<String, dynamic>>>
  getLinkedSeniorCitizens() async {
    return await ApiService.get(
      '/api/family-members/me/linked-senior-citizens',
    );
  }

  // Link a senior citizen (for family members)
  static Future<ApiResponse<Map<String, dynamic>>> linkSeniorCitizen({
    required String seniorCitizenEmail,
    required String relation,
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
      'senior_citizen_email': seniorCitizenEmail,
      'relation': relation,
    };

    return await ApiService.post(
      '/api/family-members/me/link-senior-citizen',
      body: body,
    );
  }
}
